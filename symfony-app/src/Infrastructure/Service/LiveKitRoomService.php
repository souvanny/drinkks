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
     * Récupère toutes les données des rooms (vérification connexion + rooms + stats)
     *
     * @return array Tableau avec 'success', 'rooms', 'participants_by_room', 'stats', 'http_status'
     */
    public function getRoomsData(): array
    {
        // Vérifier la connexion Redis
        if (!$this->isRedisConnected()) {
            return [
                'success' => false,
                'error' => 'Impossible de se connecter à Redis',
                'redis_status' => 'disconnected',
                'http_status' => Response::HTTP_INTERNAL_SERVER_ERROR
            ];
        }

        // Récupérer toutes les rooms
        $rooms = $this->getAllRoomsWithParticipants();

        // Récupérer les stats Redis
        $redisStats = $this->getRedisStats();

        // Récupérer toutes les venues pour avoir les informations sur les places
        $venues = $this->venueRepository->findAll();

        // Créer un mapping venue_name => nbSeat total
        $venueTotalSeatsMap = [];
        foreach ($venues as $venue) {
            $venueTotalSeatsMap[$venue->getName()] = $venue->getNbSeat();
        }

        // Initialiser les compteurs de places occupées
        $nbSeatsOccupiedByVenue = [];
        $nbSeatsOccupiedByRoom = [];

        // Construire les participants par room
        $participantsByRoom = [];
        foreach ($rooms as $room) {
            $participantsByRoom[$room['name']] = [
                'count' => $room['participants_count'],
                'participants' => $room['participants'],
            ];

            // Nombre de places occupées dans cette room = nombre de participants
            $nbSeatsOccupiedByRoom[$room['name']] = $room['participants_count'];

            // Décomposer le nom de la room pour extraire le nom du venue
            $roomNameParts = explode(' : ', $room['name']);
            $venueName = $roomNameParts[0]; // "Le 7ème Ciel"

            // Ajouter aux places occupées par venue
            if (!isset($nbSeatsOccupiedByVenue[$venueName])) {
                $nbSeatsOccupiedByVenue[$venueName] = 0;
            }
            $nbSeatsOccupiedByVenue[$venueName] += $room['participants_count'];
        }

        return [
            'success' => true,
            'rooms' => $rooms,
            'participants_by_room' => $participantsByRoom,
            'nb_seats_by_venues' => $nbSeatsOccupiedByVenue, // Places OCCUPÉES par venue
            'nb_seats_by_room' => $nbSeatsOccupiedByRoom,    // Places OCCUPÉES par room
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
            // Vérifier la connexion Redis
            if (!$this->redisLiveKitService->testConnection()) {
                $this->logger->warning('Redis non disponible pour récupérer les rooms');
                return [];
            }

            // Récupérer toutes les rooms
            $rooms = $this->redisLiveKitService->getAllRooms();

            $roomsList = [];

            foreach ($rooms as $room) {
                $roomsList[] = [
                    'name' => $room['name'],
                    'node' => $room['node'] ?? null,
                    'participants_count' => $room['participants_count'] ?? 0,
                    'participants' => array_map(function($identity) {
                        return [
                            'identity' => $identity,
                        ];
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
