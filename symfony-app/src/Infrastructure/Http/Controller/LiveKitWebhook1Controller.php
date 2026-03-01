<?php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Service\LiveKitRoomService;
use App\Infrastructure\Service\SfuService;
use App\Infrastructure\Service\RedisLiveKitService;
use Exception;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/sfu')]
#[OA\Tag(name: 'sfu')]
class LiveKitWebhook1Controller extends AbstractController
{

    public function __construct(
        private readonly SfuService $sfuService,
        private readonly RedisLiveKitService $redisLiveKitService,
        private readonly LiveKitRoomService $liveKitRoomService,
    ) {
    }

    /**
     * Récupère la liste des rooms et participants depuis Redis
     */
    #[Route('/webhook1', name: 'sfu_webhook1', methods: ['GET'])]
    #[OA\Get(
        path: '/api/sfu/webhook1',
        summary: 'Liste toutes les rooms et participants',
        tags: ['sfu'],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Liste des rooms récupérée avec succès'
            ),
            new OA\Response(
                response: 500,
                description: 'Erreur serveur'
            )
        ]
    )]
    public function listRooms(): JsonResponse
    {
        try {
            // Vérifier la connexion Redis
            if (!$this->liveKitRoomService->isRedisConnected()) {
                return $this->json([
                    'success' => false,
                    'error' => 'Impossible de se connecter à Redis',
                    'redis_status' => 'disconnected'
                ], Response::HTTP_INTERNAL_SERVER_ERROR);
            }

            // Récupérer toutes les rooms avec le nouveau service
            $rooms = $this->liveKitRoomService->getAllRoomsWithParticipants();

            // Récupérer les stats Redis
            $redisStats = $this->liveKitRoomService->getRedisStats();

            // Construire la réponse
            $participantsByRoom = [];
            foreach ($rooms as $room) {
                $participantsByRoom[$room['name']] = [
                    'count' => $room['participants_count'],
                    'participants' => $room['participants'],
                ];
            }

            return $this->json([
                'success' => true,
                'data' => [
                    'rooms' => $rooms,
                    'participants_by_room' => $participantsByRoom,
                    'summary' => [
                        'total_rooms' => count($rooms),
                        'total_participants' => array_sum(array_column($rooms, 'participants_count')),
                    ],
                ],
                'meta' => [
                    'redis' => [
                        'status' => 'connected',
                        'stats' => $redisStats,
                    ],
                    'timestamp' => time(),
                ],
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => 'Erreur lors de la récupération des données: ' . $e->getMessage(),
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }



    /**
     * Récupère les détails d'une room spécifique
     */
    #[Route('/webhook1/room/{roomName}', name: 'sfu_webhook1_room', methods: ['GET'])]
    public function getRoomDetails(string $roomName): JsonResponse
    {
        try {
            if (!$this->redisLiveKitService->testConnection()) {
                return $this->json([
                    'success' => false,
                    'error' => 'Redis non disponible'
                ], Response::HTTP_INTERNAL_SERVER_ERROR);
            }

            $participantsCount = $this->redisLiveKitService->getParticipantsCount($roomName);
            $participants = $this->redisLiveKitService->getParticipantsIdentities($roomName);
            $metadata = $this->redisLiveKitService->getRoomMetadata($roomName);

            return $this->json([
                'success' => true,
                'data' => [
                    'name' => $roomName,
                    'participants_count' => $participantsCount,
                    'participants' => $participants,
                    'metadata' => $metadata,
                ]
            ]);

        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Endpoint de test pour Redis
     */
    #[Route('/redis-test', name: 'sfu_redis_test', methods: ['GET'])]
    public function testRedis(): JsonResponse
    {
        try {
            $connected = $this->redisLiveKitService->testConnection();

            if (!$connected) {
                return $this->json([
                    'success' => false,
                    'status' => 'disconnected',
                    'message' => 'Impossible de se connecter à Redis'
                ], Response::HTTP_INTERNAL_SERVER_ERROR);
            }

            $stats = $this->redisLiveKitService->getStats();
            $nodes = $this->redisLiveKitService->getActiveNodes();

            return $this->json([
                'success' => true,
                'status' => 'connected',
                'redis' => $stats,
                'nodes' => $nodes,
                'config' => [
                    'host' => $_ENV['REDIS_HOST'] ?? 'non défini',
                    'port' => $_ENV['REDIS_PORT'] ?? 'non défini',
                ]
            ]);

        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Version alternative avec plus de détails sur les participants
     */
    #[Route('/webhook1/detailed', name: 'sfu_webhook1_detailed', methods: ['GET'])]
    public function listRoomsDetailed(): JsonResponse
    {
        try {
            if (!$this->redisLiveKitService->testConnection()) {
                throw new \Exception('Redis non disponible');
            }

            $rooms = $this->redisLiveKitService->getAllRooms();
            $nodes = $this->redisLiveKitService->getActiveNodes();

            $detailedRooms = [];

            foreach ($rooms as $room) {
                // Récupérer les données brutes des participants
                $rawParticipants = $this->redisLiveKitService->getParticipantsRaw($room['name']);

                $participantsDetailed = [];
                foreach ($rawParticipants as $identity => $protoData) {
                    // Ici vous pourriez désérialiser le protobuf si nécessaire
                    $participantsDetailed[] = [
                        'identity' => $identity,
                        'data_length' => strlen($protoData),
                        'has_data' => !empty($protoData),
                    ];
                }

                $detailedRooms[] = [
                    'name' => $room['name'],
                    'node' => $room['node'],
                    'node_info' => $nodes[$room['node']] ?? null,
                    'participants' => [
                        'count' => $room['participants_count'],
                        'list' => $participantsDetailed,
                    ],
                ];
            }

            return $this->json([
                'success' => true,
                'data' => $detailedRooms,
                'meta' => [
                    'total_rooms' => count($detailedRooms),
                    'total_participants' => array_sum(array_column($detailedRooms, 'participants.count')),
                    'active_nodes' => count($nodes),
                ],
            ]);

        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }


    #[Route('/redis-debug-env1', name: 'sfu_redis_debug_env1', methods: ['GET'])]
    public function debugRedisEnv1(): JsonResponse
    {
        // Récupérer les variables d'environnement
        $envVars = [
            'REDIS_HOST' => $_ENV['REDIS_HOST'] ?? getenv('REDIS_HOST'),
            'REDIS_PORT' => $_ENV['REDIS_PORT'] ?? getenv('REDIS_PORT'),
            'REDIS_PASSWORD' => isset($_ENV['REDIS_PASSWORD']) ? '***présent***' : (getenv('REDIS_PASSWORD') ? '***présent***' : 'non défini'),
            'env_file_exists' => file_exists(__DIR__ . '/../../../.env'),
            'env_local_exists' => file_exists(__DIR__ . '/../../../.env.local'),
        ];

        // Tester la connexion manuellement
        try {
            $testClient = new \Predis\Client([
                'scheme' => 'tcp',
                'host' => $_ENV['REDIS_HOST'] ?? '188.165.212.127',
                'port' => $_ENV['REDIS_PORT'] ?? 6379,
                'password' => $_ENV['REDIS_PASSWORD'] ?? '',
            ]);
            $ping = $testClient->ping();
            $connectionTest = 'Succès: ' . $ping;
        } catch (\Exception $e) {
            $connectionTest = 'Échec: ' . $e->getMessage();
        }

        return $this->json([
            'env_vars' => $envVars,
            'connection_test' => $connectionTest,
            'dsn_used' => 'redis://' . ($_ENV['REDIS_PASSWORD'] ? '***' : 'PASSWORD_MANQUANT') . '@' . ($_ENV['REDIS_HOST'] ?? '?') . ':' . ($_ENV['REDIS_PORT'] ?? '?') . '/0',
        ]);
    }

    #[Route('/redis-debug-env2', name: 'sfu_redis_debug_env2', methods: ['GET'])]
    public function debugRedisEnv2(): JsonResponse
    {
        // Récupérer les variables d'environnement
        $envVars = [
            'REDIS_HOST' => $_ENV['REDIS_HOST'] ?? getenv('REDIS_HOST'),
            'REDIS_PORT' => $_ENV['REDIS_PORT'] ?? getenv('REDIS_PORT'),
            'REDIS_PASSWORD' => isset($_ENV['REDIS_PASSWORD']) ? '***présent***' : (getenv('REDIS_PASSWORD') ? '***présent***' : 'non défini'),
            'REDIS_PASSWORD_LENGTH' => strlen($_ENV['REDIS_PASSWORD'] ?? getenv('REDIS_PASSWORD') ?? ''),
            'env_file_exists' => file_exists(__DIR__ . '/../../../.env'),
            'env_local_exists' => file_exists(__DIR__ . '/../../../.env.local'),
        ];

        // Tester la connexion manuelle
        try {
            $testClient = new \Predis\Client([
                'scheme' => 'tcp',
                'host' => $_ENV['REDIS_HOST'] ?? getenv('REDIS_HOST') ?? '188.165.212.127',
                'port' => $_ENV['REDIS_PORT'] ?? getenv('REDIS_PORT') ?? 6379,
                'password' => $_ENV['REDIS_PASSWORD'] ?? getenv('REDIS_PASSWORD') ?? '',
            ]);
            $ping = $testClient->ping();
            $connectionTest = 'Succès: ' . $ping;
        } catch (\Exception $e) {
            $connectionTest = 'Échec: ' . $e->getMessage();
        }

        // Tester le service injecté
        try {
            $serviceTest = $this->redisLiveKitService->testConnection();
            $injectedTest = $serviceTest ? 'Succès' : 'Échec (testConnection retourne false)';
        } catch (\Exception $e) {
            $injectedTest = 'Exception: ' . $e->getMessage();
        }

        return $this->json([
            'env_vars' => $envVars,
            'manual_connection' => $connectionTest,
            'injected_service' => $injectedTest,
            'dsn_used' => 'redis://' . (($envVars['REDIS_PASSWORD'] === '***présent***') ? '***' : 'PASSWORD_MANQUANT') . '@' . ($envVars['REDIS_HOST'] ?? '?') . ':' . ($envVars['REDIS_PORT'] ?? '?') . '/0',
        ]);
    }
}
