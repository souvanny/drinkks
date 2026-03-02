<?php
// src/Infrastructure/Service/LiveKitRoomService.php

namespace App\Infrastructure\Service;

use App\Infrastructure\Persistence\Doctrine\Repository\VenueRepository;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\Response;

class LiveKitRoomService
{
    public function __construct(
        private readonly RedisLiveKitService $redisLiveKitService,
        private readonly VenueRepository $venueRepository,
        private readonly LoggerInterface $logger,
    ) {
    }

    /**
     * Agrège les données des venues avec les statistiques des rooms
     *
     * @param array $venues Liste des venues formatées
     * @param array $roomsStats Statistiques des rooms
     * @return array Venues enrichies avec les nouvelles propriétés
     */
    public function aggregateVenuesAndStats(array $venues, array $roomsStats): array
    {
        $enrichedVenues = [];

        foreach ($venues as $venue) {
            $venueUuid = $venue['uuid'];

            $totalParticipants = 0;
            $nbParticipantsByTable = [];
            $nbSeatsByTable = [];

            foreach ($roomsStats['rooms'] as $room) {
                $roomNameParts = explode(' : ', $room['name']);

                if (count($roomNameParts) === 2 && $roomNameParts[0] === $venueUuid) {
                    $tableNumber = $roomNameParts[1];
                    $participantsCount = $room['participants_count'];

                    $totalParticipants += $participantsCount;
                    $nbParticipantsByTable[$tableNumber] = $participantsCount;
                    $nbSeatsByTable[$tableNumber] = $venue['seats_per_table'];
                }
            }

            $enrichedVenues[] = array_merge($venue, [
                'total_participants' => $totalParticipants,
                'nb_participants_by_table' => $nbParticipantsByTable,
                'nb_seats_by_table' => $nbSeatsByTable,
                'tables_available' => $venue['nb_tables'] - count($nbParticipantsByTable),
                'occupancy_rate' => $venue['total_capacity'] > 0
                    ? round(($totalParticipants / $venue['total_capacity']) * 100, 1)
                    : 0,
            ]);
        }

        return $enrichedVenues;
    }

    /**
     * Agrège les données d'un venue spécifique avec les statistiques des rooms
     *
     * @param array $venueData Données du venue (uuid, name, nb_tables, seats_per_table, total_capacity)
     * @param array $roomsStats Statistiques des rooms
     * @return array Données enrichies du venue
     */
    public function aggregateVenueTables(array $venueData, array $roomsStats): array
    {
        $venueUuid = $venueData['venue_uuid'];
        $seatsPerTable = $venueData['seats_per_table'] ?? 4;

        $nbParticipantsByTable = [];
        $nbSeatsByTable = [];

        foreach ($roomsStats['rooms'] as $room) {
            $roomNameParts = explode(' : ', $room['name']);

            if (count($roomNameParts) === 2 && $roomNameParts[0] === $venueUuid) {
                $tableNumber = $roomNameParts[1];
                $nbParticipantsByTable[$tableNumber] = $room['participants_count'];
                $nbSeatsByTable[$tableNumber] = $seatsPerTable;
            }
        }

        return array_merge($venueData, [
            'nb_participants_by_table' => $nbParticipantsByTable,
            'nb_seats_by_table' => $nbSeatsByTable,
            'active_tables' => count($nbParticipantsByTable),
            'available_tables' => $venueData['nb_tables'] - count($nbParticipantsByTable),
        ]);
    }

    /**
     * Récupère toutes les données des rooms (vérification connexion + rooms + stats)
     *
     * @return array Tableau avec 'success', 'rooms', 'participants_by_room', 'stats', 'http_status'
     */
    public function getRoomsData(): array
    {
        if (!$this->isRedisConnected()) {
            return [
                'success' => false,
                'error' => 'Impossible de se connecter à Redis',
                'redis_status' => 'disconnected',
                'http_status' => Response::HTTP_INTERNAL_SERVER_ERROR
            ];
        }

        $rooms = $this->getAllRoomsWithParticipants();
        $redisStats = $this->getRedisStats();
        $venues = $this->venueRepository->findAll();

        $venueTotalSeatsMap = [];
        foreach ($venues as $venue) {
            $venueTotalSeatsMap[$venue->getName()] = $venue->getNbTables() * $venue->getSeatsPerTable();
        }

        $nbSeatsOccupiedByVenue = [];
        $nbSeatsOccupiedByRoom = [];
        $participantsByRoom = [];

        foreach ($rooms as $room) {
            $participantsByRoom[$room['name']] = [
                'count' => $room['participants_count'],
                'participants' => $room['participants'],
            ];

            $nbSeatsOccupiedByRoom[$room['name']] = $room['participants_count'];

            $roomNameParts = explode(' : ', $room['name']);
            $venueUuid = $roomNameParts[0];

            if (!isset($nbSeatsOccupiedByVenue[$venueUuid])) {
                $nbSeatsOccupiedByVenue[$venueUuid] = 0;
            }
            $nbSeatsOccupiedByVenue[$venueUuid] += $room['participants_count'];
        }

        return [
            'success' => true,
            'rooms' => $rooms,
            'participants_by_room' => $participantsByRoom,
            'nb_seats_by_venues' => $nbSeatsOccupiedByVenue,
            'nb_seats_by_room' => $nbSeatsOccupiedByRoom,
            'stats' => [
                'rooms' => $rooms,
                'participants_by_room' => $participantsByRoom,
                'nb_seats_by_venues' => $nbSeatsOccupiedByVenue,
                'nb_seats_by_room' => $nbSeatsOccupiedByRoom,
                'summary' => [
                    'total_rooms' => count($rooms),
                    'total_participants' => array_sum(array_column($rooms, 'participants_count')),
                ],
            ],
            'redis_stats' => $redisStats,
            'http_status' => Response::HTTP_OK
        ];
    }

    /**
     * Version simplifiée qui retourne uniquement les stats pour les controllers
     */
    public function getRoomsStats(): array
    {
        $data = $this->getRoomsData();

        if (!$data['success']) {
            return [
                'rooms' => [],
                'participants_by_room' => [],
                'nb_seats_by_venues' => [],
                'nb_seats_by_room' => [],
                'summary' => [
                    'total_rooms' => 0,
                    'total_participants' => 0,
                ],
            ];
        }

        return $data['stats'];
    }

    /**
     * Vérifie si la connexion Redis est OK et retourne une réponse JSON d'erreur si nécessaire
     *
     * @return array|null Retourne null si OK, sinon un tableau avec la réponse JSON
     */
    public function checkRedisConnection(): ?array
    {
        if (!$this->isRedisConnected()) {
            return [
                'success' => false,
                'error' => 'Impossible de se connecter à Redis',
                'redis_status' => 'disconnected'
            ];
        }
        return null;
    }

    /**
     * Récupère toutes les rooms avec leurs participants depuis Redis
     *
     * @return array Tableau de rooms avec leurs participants
     */
    public function getAllRoomsWithParticipants(): array
    {
        try {
            if (!$this->redisLiveKitService->testConnection()) {
                $this->logger->warning('Redis non disponible pour récupérer les rooms');
                return [];
            }

            $rooms = $this->redisLiveKitService->getAllRooms();
            $roomsList = [];

            foreach ($rooms as $room) {
                $roomsList[] = [
                    'name' => $room['name'],
                    'node' => $room['node'] ?? null,
                    'participants_count' => $room['participants_count'] ?? 0,
                    'participants' => array_map(function($identity) {
                        return ['identity' => $identity];
                    }, $room['participants'] ?? []),
                ];
            }

            return $roomsList;

        } catch (\Exception $e) {
            $this->logger->error('Erreur lors de la récupération des rooms: ' . $e->getMessage());
            return [];
        }
    }

    /**
     * Récupère les détails d'une room spécifique
     */
    public function getRoomDetails(string $roomName): ?array
    {
        try {
            if (!$this->redisLiveKitService->testConnection()) {
                return null;
            }

            $participantsCount = $this->redisLiveKitService->getParticipantsCount($roomName);
            $participants = $this->redisLiveKitService->getParticipantsIdentities($roomName);
            $metadata = $this->redisLiveKitService->getRoomMetadata($roomName);

            if ($participantsCount === 0 && empty($participants) && !$metadata) {
                return null;
            }

            return [
                'name' => $roomName,
                'participants_count' => $participantsCount,
                'participants' => array_map(function($identity) {
                    return ['identity' => $identity];
                }, $participants),
                'metadata' => $metadata,
            ];

        } catch (\Exception $e) {
            $this->logger->error("Erreur pour la room {$roomName}: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Récupère les statistiques Redis
     */
    public function getRedisStats(): array
    {
        try {
            return $this->redisLiveKitService->getStats();
        } catch (\Exception $e) {
            $this->logger->error('Erreur stats Redis: ' . $e->getMessage());
            return [];
        }
    }

    /**
     * Vérifie si Redis est connecté
     */
    public function isRedisConnected(): bool
    {
        return $this->redisLiveKitService->testConnection();
    }
}
