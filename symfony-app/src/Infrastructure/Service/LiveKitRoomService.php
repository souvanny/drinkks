<?php
// src/Infrastructure/Service/LiveKitRoomService.php

namespace App\Infrastructure\Service;

use Psr\Log\LoggerInterface;

class LiveKitRoomService
{
    public function __construct(
        private readonly RedisLiveKitService $redisLiveKitService,
        private readonly LoggerInterface $logger,
    ) {
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
