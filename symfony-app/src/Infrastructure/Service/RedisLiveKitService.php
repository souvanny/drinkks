<?php

namespace App\Infrastructure\Service;

use Predis\Client as RedisClient;
use Psr\Log\LoggerInterface;

class RedisLiveKitService
{
    public function __construct(
        private RedisClient $redisClient,
        private LoggerInterface $logger,
    ) {
    }

    /**
     * Teste la connexion Redis
     */
    public function testConnection(): bool
    {
        try {
            return $this->redisClient->ping() === 'PONG';
        } catch (\Exception $e) {
            $this->logger->error('Erreur de connexion Redis: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Récupère la liste de toutes les rooms
     */
    public function getAllRooms(): array
    {
        try {
            // HGETALL rooms retourne un tableau avec [clé1, valeur1, clé2, valeur2, ...]
            $roomsData = $this->redisClient->hgetall('rooms');
            $roomNodeMap = $this->redisClient->hgetall('room_node_map');

            $rooms = [];

            // Traitement des données Redis (format: [nom1, proto1, nom2, proto2, ...])
            $roomNames = [];
            foreach ($roomsData as $key => $value) {
                if (is_numeric($key) && $key % 2 === 0) {
                    // Les clés paires sont les noms des rooms
                    $roomNames[] = $value;
                }
            }

            // Si le format est différent, on utilise array_keys
            if (empty($roomNames)) {
                $roomNames = array_keys($roomsData);
            }

            foreach ($roomNames as $roomName) {
                $rooms[] = [
                    'name' => $roomName,
                    'node' => $roomNodeMap[$roomName] ?? null,
                    'participants_count' => $this->getParticipantsCount($roomName),
                    'participants' => $this->getParticipantsIdentities($roomName),
                ];
            }

            return $rooms;

        } catch (\Exception $e) {
            $this->logger->error('Erreur lors de la récupération des rooms Redis: ' . $e->getMessage());
            return [];
        }
    }

    /**
     * Récupère les identités des participants d'une room
     */
    public function getParticipantsIdentities(string $roomName): array
    {
        try {
            $key = "room_participants:{$roomName}";
            return $this->redisClient->hkeys($key);
        } catch (\Exception $e) {
            $this->logger->error("Erreur lors de la récupération des participants pour {$roomName}: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Récupère les participants avec leurs données brutes (protobuf)
     */
    public function getParticipantsRaw(string $roomName): array
    {
        try {
            $key = "room_participants:{$roomName}";
            return $this->redisClient->hgetall($key);
        } catch (\Exception $e) {
            $this->logger->error("Erreur lors de la récupération des participants bruts pour {$roomName}: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Compte les participants d'une room
     */
    public function getParticipantsCount(string $roomName): int
    {
        try {
            $key = "room_participants:{$roomName}";
            return $this->redisClient->hlen($key);
        } catch (\Exception $e) {
            $this->logger->error("Erreur lors du comptage des participants pour {$roomName}: " . $e->getMessage());
            return 0;
        }
    }

    /**
     * Récupère les métadonnées d'une room
     */
    public function getRoomMetadata(string $roomName): ?string
    {
        try {
            // Les métadonnées peuvent être stockées dans une clé spécifique
            // ou dans la valeur du hash 'rooms'
            $roomData = $this->redisClient->hget('rooms', $roomName);
            return $roomData ?: null;
        } catch (\Exception $e) {
            $this->logger->error("Erreur lors de la récupération des métadonnées pour {$roomName}: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Récupère la liste des nœuds actifs
     */
    public function getActiveNodes(): array
    {
        try {
            return $this->redisClient->hgetall('nodes');
        } catch (\Exception $e) {
            $this->logger->error('Erreur lors de la récupération des nœuds: ' . $e->getMessage());
            return [];
        }
    }

    /**
     * Récupère des statistiques Redis
     */
    public function getStats(): array
    {
        try {
            $info = $this->redisClient->info();
            return [
                'version' => $info['redis_version'] ?? 'unknown',
                'connected_clients' => $info['connected_clients'] ?? 0,
                'used_memory_human' => $info['used_memory_human'] ?? 'unknown',
                'uptime_in_days' => $info['uptime_in_days'] ?? 0,
            ];
        } catch (\Exception $e) {
            $this->logger->error('Erreur lors de la récupération des stats Redis: ' . $e->getMessage());
            return [];
        }
    }
}
