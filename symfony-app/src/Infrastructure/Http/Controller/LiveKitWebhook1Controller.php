<?php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Service\SfuService;
use Exception;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Contracts\Cache\CacheInterface;
use Agence104\LiveKit\RoomServiceClient;
use Agence104\LiveKit\RoomCreateOptions;

#[Route('/api/sfu')]
#[OA\Tag(name: 'sfu')]
class LiveKitWebhook1Controller extends AbstractController
{
    public function __construct(
        private readonly SfuService $sfuService,
        private readonly CacheInterface $redisLivekitPool,
    ) {
    }

    #[Route('/webhook1', name: 'sfu_webhook1', methods: ['GET'])]
    public function listRooms(): JsonResponse
    {
        try {
            // Connexion directe à Redis (alternative si le pool ne suffit pas)
            $redis = new \Predis\Client([
                'scheme' => 'tcp',
                'host'   => $_ENV['REDIS_HOST'] ?? '127.0.0.1',
                'port'   => $_ENV['REDIS_PORT'] ?? 6379,
            ]);

            // 1. Récupérer toutes les rooms depuis Redis
            $roomsData = $redis->hgetall('rooms');
            $roomNodeMap = $redis->hgetall('room_node_map');

            $rooms = [];
            $allParticipants = [];

            foreach ($roomsData as $roomName => $roomProto) {
                // Désérialiser le protobuf Room (si nécessaire)
                // Note: Les données sont stockées en protobuf, pas directement lisibles
                $rooms[$roomName] = [
                    'name' => $roomName,
                    'sid' => $this->extractSidFromProto($roomProto), // Méthode à implémenter
                    'node' => $roomNodeMap[$roomName] ?? null,
                    'num_participants' => 0, // Sera mis à jour
                ];

                // 2. Récupérer les participants pour cette room
                $participantsKey = "room_participants:{$roomName}";
                $participantsData = $redis->hgetall($participantsKey);

                $participants = [];
                foreach ($participantsData as $identity => $participantProto) {
                    // Extraire les infos de base du participant
                    $participants[$identity] = [
                        'identity' => $identity,
                        // D'autres champs nécessitent désérialisation protobuf
                    ];

                    // Optionnel: compter les pistes (audio/video/data)
                    $tracksKey = "room_tracks:{$roomName}:{$identity}";
                    $participants[$identity]['track_count'] = $redis->hlen($tracksKey);
                }

                $rooms[$roomName]['num_participants'] = count($participants);
                $rooms[$roomName]['participants'] = $participants;

                $allParticipants[$roomName] = $participants;
            }

            return $this->json([
                'success' => true,
                'rooms' => $rooms,
                'participants_by_room' => $allParticipants,
                'total_rooms' => count($rooms),
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => 'Erreur Redis: ' . $e->getMessage(),
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Version simplifiée avec l'API Redis et utilisation des commandes brutes
     */
    #[Route('/webhook2/redis-direct', name: 'sfu_webhook_redis_direct', methods: ['GET'])]
    public function listRoomsDirect(): JsonResponse
    {
        try {
            $redis = new \Predis\Client([
                'scheme' => 'tcp',
                'host'   => $_ENV['REDIS_HOST'] ?? '127.0.0.1',
                'port'   => $_ENV['REDIS_PORT'] ?? 6379,
            ]);

            // Récupérer toutes les clés de rooms
            $roomNames = $redis->hkeys('rooms');

            $result = [];

            foreach ($roomNames as $roomName) {
                // Compter les participants avec HLEN
                $participantsCount = $redis->hlen("room_participants:{$roomName}");

                // Récupérer les identités des participants
                $participants = $redis->hkeys("room_participants:{$roomName}");

                // Récupérer le node qui gère cette room
                $node = $redis->hget('room_node_map', $roomName);

                $result[] = [
                    'name' => $roomName,
                    'participants_count' => $participantsCount,
                    'participants' => $participants,
                    'node' => $node,
                ];
            }

            return $this->json([
                'success' => true,
                'data' => $result,
                'total' => count($result),
            ]);

        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Version avec CacheInterface de Symfony
     */
    #[Route('/webhook3/cache', name: 'sfu_webhook_cache', methods: ['GET'])]
    public function listRoomsWithCache(): JsonResponse
    {
        try {
            // Utiliser le cache Symfony pour interagir avec Redis
            $cacheItem = $this->redisLivekitPool->getItem('livekit_rooms_snapshot');

            // Mettre en cache le résultat pendant 5 secondes pour éviter de surcharger Redis
            if (!$cacheItem->isHit()) {
                $redis = new \Predis\Client([
                    'scheme' => 'tcp',
                    'host'   => $_ENV['REDIS_HOST'] ?? '127.0.0.1',
                    'port'   => $_ENV['REDIS_PORT'] ?? 6379,
                ]);

                $roomNames = $redis->hkeys('rooms');
                $data = [];

                foreach ($roomNames as $roomName) {
                    $participantsCount = $redis->hlen("room_participants:{$roomName}");
                    $participants = $redis->hkeys("room_participants:{$roomName}");
                    $node = $redis->hget('room_node_map', $roomName);

                    $data[] = [
                        'name' => $roomName,
                        'participants_count' => $participantsCount,
                        'participants' => $participants,
                        'node' => $node,
                    ];
                }

                $cacheItem->set($data);
                $cacheItem->expiresAfter(5); // Cache pendant 5 secondes
                $this->redisLivekitPool->save($cacheItem);
            }

            return $this->json([
                'success' => true,
                'data' => $cacheItem->get(),
                'cached' => !$cacheItem->isHit(),
            ]);

        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Méthode utilitaire pour extraire le SID d'un protobuf Room
     * Note: À améliorer avec la vraie désérialisation protobuf
     */
    private function extractSidFromProto(string $proto): string
    {
        // Tentative d'extraction basique - À remplacer par une vraie désérialisation
        // avec la bibliothèque protobuf de LiveKit
        if (preg_match('/sid:"([^"]+)"/', $proto, $matches)) {
            return $matches[1];
        }

        // Fallback: utiliser un hash du nom
        return md5($proto);
    }
}
