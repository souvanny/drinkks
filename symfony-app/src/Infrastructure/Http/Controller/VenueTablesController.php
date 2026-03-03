<?php
// src/Infrastructure/Http/Controller/VenueTablesController.php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Persistence\Doctrine\Repository\VenueRepository;
use App\Infrastructure\Service\LiveKitRoomService;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/venue/tables')]
#[OA\Tag(name: 'venue')]
class VenueTablesController extends AbstractController
{
    public function __construct(
        private readonly VenueRepository $venueRepository,
        private readonly LiveKitRoomService $liveKitRoomService,
    ) {}

    #[Route('/list', name: 'venue_tables_list', methods: ['GET'])]
    #[OA\Get(
        summary: 'Récupère les tables actives pour un lieu',
        parameters: [
            new OA\Parameter(
                name: 'venue',
                description: 'UUID du lieu',
                in: 'query',
                required: true,
                schema: new OA\Schema(type: 'string', format: 'uuid')
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Informations sur les tables du lieu',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'venue_uuid', type: 'string'),
                        new OA\Property(property: 'venue_name', type: 'string'),
                        new OA\Property(property: 'nb_tables', type: 'integer'),
                        new OA\Property(property: 'seats_per_table', type: 'integer'),
                        new OA\Property(property: 'total_capacity', type: 'integer'),
                        new OA\Property(property: 'nb_participants_by_table', type: 'object'),
                        new OA\Property(property: 'nb_seats_by_table', type: 'object'),
                        new OA\Property(property: 'active_tables', type: 'integer'),
                        new OA\Property(property: 'available_tables', type: 'integer'),
                        new OA\Property(property: 'stats', type: 'object'),
                    ]
                )
            ),
            new OA\Response(response: 400, description: 'Paramètre venue manquant'),
            new OA\Response(response: 404, description: 'Lieu non trouvé')
        ]
    )]
    public function list(Request $request): JsonResponse
    {
        $venueUuid = $request->query->get('venue');

        if (!$venueUuid) {
            return $this->json(['error' => 'Le paramètre "venue" est requis'], Response::HTTP_BAD_REQUEST);
        }

        $venue = $this->venueRepository->findByUuid($venueUuid);

        if (!$venue) {
            return $this->json(['error' => 'Lieu non trouvé'], Response::HTTP_NOT_FOUND);
        }

        $roomsStats = $this->liveKitRoomService->getRoomsStats();

        $venueData = [
            'venueUuid' => $venue->getUuid(),
            'venueName' => $venue->getName(),
            'nbTables' => $venue->getNbTables(),
            'seatsPerTable' => $venue->getSeatsPerTable(),
            'totalCapacity' => $venue->getTotalCapacity(),
        ];

        $enrichedVenueData = $this->liveKitRoomService->aggregateVenueTables($venueData, $roomsStats);


        return $this->json(array_merge($enrichedVenueData, [
            'stats' => $roomsStats,
        ]));
    }


}
