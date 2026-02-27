<?php
// src/Infrastructure/Http/Controller/VenueTablesController.php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Persistence\Doctrine\Repository\VenueRepository;
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
    ) {}

    #[Route('/list', name: 'venue_tables_list', methods: ['GET'])]
    #[OA\Get(
        summary: 'Récupère le nombre de tables disponibles pour un lieu',
        parameters: [
            new OA\Parameter(
                name: 'venue',
                in: 'query',
                required: true,
                description: 'UUID du lieu',
                schema: new OA\Schema(type: 'string', format: 'uuid')
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Informations sur le nombre de tables',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'venue_uuid', type: 'string'),
                        new OA\Property(property: 'venue_name', type: 'string'),
                        new OA\Property(property: 'nb_seats', type: 'integer'),
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

        return $this->json([
            'venue_uuid' => $venue->getUuid(),
            'venue_name' => $venue->getName(),
            'nb_seats' => $venue->getNbSeat(),
        ]);
    }
}
