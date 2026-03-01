<?php

namespace App\Infrastructure\Http\Controller;

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
            $redisConnected = $this->redisLiveKitService->testConnection();

            if (!$redisConnected) {
                return $this->json([
                    'success' => false,
                    'error' => 'Impossible de se connecter à Redis',
                    'redis_status' => 'disconnected'
                ], Response::HTTP_INTERNAL_SERVER_ERROR);
            }

            // Récupérer toutes les rooms
            $rooms = $this->redisLiveKitService->getAllRooms();

            // Construire la structure de réponse
            $roomsList = [];
            $participantsByRoom = [];

            foreach ($rooms as $room) {
                $roomsList[] = [
                    'name' => $room['name'],
                    'node' => $room['node'],
                    'participants_count' => $room['participants_count'],
                ];

                // Récupérer les détails des participants pour cette room
                $participants = $room['participants'];

                // Pour chaque participant, on pourrait récupérer plus d'infos
                $participantsDetails = [];
                foreach ($participants as $identity) {
                    $participantsDetails[] = [
                        'identity' => $identity,
                        // D'autres infos pourraient être ajoutées ici
                        // comme l'état, les métadonnées, etc.
                    ];
                }

                $participantsByRoom[$room['name']] = [
                    'count' => $room['participants_count'],
                    'participants' => $participantsDetails,
                ];
            }

            // Récupérer les stats Redis
            $redisStats = $this->redisLiveKitService->getStats();

            return $this->json([
                'success' => true,
                'data' => [
                    'rooms' => $roomsList,
                    'participants_by_room' => $participantsByRoom,
                    'summary' => [
                        'total_rooms' => count($roomsList),
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
}
