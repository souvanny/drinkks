<?php
// src/Infrastructure/Http/Controller/VenueController.php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Persistence\Doctrine\Entity\VenueEntity;
use App\Infrastructure\Persistence\Doctrine\Repository\VenueRepository;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Uid\Uuid;

#[Route('/api/venue')]
#[OA\Tag(name: 'venue')]
class VenueController extends AbstractController
{
    public function __construct(
        private readonly VenueRepository $venueRepository,
        private readonly SerializerInterface $serializer,
        private readonly ValidatorInterface $validator,
    ) {}

    #[Route('/list', name: 'venue_list', methods: ['GET'])]
    #[OA\Get(
        summary: 'Liste des venues avec pagination',
        parameters: [
            new OA\Parameter(
                name: 'page',
                in: 'query',
                description: 'Numéro de page',
                schema: new OA\Schema(type: 'integer', default: 1)
            ),
            new OA\Parameter(
                name: 'limit',
                in: 'query',
                description: 'Nombre d\'éléments par page',
                schema: new OA\Schema(type: 'integer', default: 20, maximum: 100)
            ),
            new OA\Parameter(
                name: 'search',
                in: 'query',
                description: 'Terme de recherche (nom ou description)',
                schema: new OA\Schema(type: 'string')
            ),
            new OA\Parameter(
                name: 'type',
                in: 'query',
                description: 'Filtre par type',
                schema: new OA\Schema(type: 'integer')
            ),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Liste paginée des venues',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'items', type: 'array', items: new OA\Items(
                            properties: [
                                new OA\Property(property: 'id', type: 'integer'),
                                new OA\Property(property: 'uuid', type: 'string'),
                                new OA\Property(property: 'name', type: 'string'),
                                new OA\Property(property: 'description', type: 'string', nullable: true),
                                new OA\Property(property: 'type', type: 'integer', nullable: true),
                                new OA\Property(property: 'rank', type: 'integer', nullable: true),
                            ]
                        )),
                        new OA\Property(property: 'total', type: 'integer'),
                        new OA\Property(property: 'page', type: 'integer'),
                        new OA\Property(property: 'limit', type: 'integer'),
                        new OA\Property(property: 'pages', type: 'integer'),
                    ]
                )
            )
        ]
    )]
    public function list(Request $request): JsonResponse
    {
        $page = max(1, (int) $request->query->get('page', 1));
        $limit = min(100, max(1, (int) $request->query->get('limit', 20)));
        $search = $request->query->get('search');
        $type = $request->query->has('type') ? (int) $request->query->get('type') : null;

        $result = $this->venueRepository->findPaginated($page, $limit, $search, $type);

        // Formater les données pour la réponse
        $items = array_map(function (VenueEntity $venue) {
            return [
                'id' => $venue->getId(),
                'uuid' => $venue->getUuid(),
                'name' => $venue->getName(),
                'description' => $venue->getDescription(),
                'type' => $venue->getType(),
                'rank' => $venue->getRank(),
            ];
        }, $result['items']);

        return $this->json([
            'items' => $items,
            'total' => $result['total'],
            'page' => $result['page'],
            'limit' => $result['limit'],
            'pages' => $result['pages'],
        ]);
    }

    #[Route('/{uuid}', name: 'venue_get', methods: ['GET'])]
    #[OA\Get(
        summary: 'Récupère un venue par son UUID',
        parameters: [
            new OA\Parameter(
                name: 'uuid',
                in: 'path',
                required: true,
                schema: new OA\Schema(type: 'string')
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Venue trouvé',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'id', type: 'integer'),
                        new OA\Property(property: 'uuid', type: 'string'),
                        new OA\Property(property: 'name', type: 'string'),
                        new OA\Property(property: 'description', type: 'string', nullable: true),
                        new OA\Property(property: 'type', type: 'integer', nullable: true),
                        new OA\Property(property: 'rank', type: 'integer', nullable: true),
                    ]
                )
            ),
            new OA\Response(response: 404, description: 'Venue non trouvé')
        ]
    )]
    public function get(string $uuid): JsonResponse
    {
        $venue = $this->venueRepository->findByUuid($uuid);

        if (!$venue) {
            return $this->json(['error' => 'Venue non trouvé'], Response::HTTP_NOT_FOUND);
        }

        return $this->json([
            'id' => $venue->getId(),
            'uuid' => $venue->getUuid(),
            'name' => $venue->getName(),
            'description' => $venue->getDescription(),
            'type' => $venue->getType(),
            'rank' => $venue->getRank(),
        ]);
    }

    #[Route('', name: 'venue_create', methods: ['POST'])]
    #[OA\Post(
        summary: 'Crée un nouveau venue',
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['name'],
                properties: [
                    new OA\Property(property: 'name', type: 'string', maxLength: 50),
                    new OA\Property(property: 'description', type: 'string', maxLength: 200, nullable: true),
                    new OA\Property(property: 'type', type: 'integer', nullable: true),
                    new OA\Property(property: 'rank', type: 'integer', nullable: true),
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: 'Venue créé avec succès',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'id', type: 'integer'),
                        new OA\Property(property: 'uuid', type: 'string'),
                        new OA\Property(property: 'name', type: 'string'),
                        new OA\Property(property: 'description', type: 'string', nullable: true),
                        new OA\Property(property: 'type', type: 'integer', nullable: true),
                        new OA\Property(property: 'rank', type: 'integer', nullable: true),
                    ]
                )
            ),
            new OA\Response(response: 400, description: 'Données invalides')
        ]
    )]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        if (!isset($data['name']) || empty($data['name'])) {
            return $this->json(['error' => 'Le nom est requis'], Response::HTTP_BAD_REQUEST);
        }

        $venue = new VenueEntity();
        $venue->setUuid(Uuid::v4()->toString());
        $venue->setName($data['name']);
        $venue->setDescription($data['description'] ?? null);
        $venue->setType($data['type'] ?? null);
        $venue->setRank($data['rank'] ?? null);

        $errors = $this->validator->validate($venue);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_BAD_REQUEST);
        }

        $this->venueRepository->save($venue);

        return $this->json([
            'id' => $venue->getId(),
            'uuid' => $venue->getUuid(),
            'name' => $venue->getName(),
            'description' => $venue->getDescription(),
            'type' => $venue->getType(),
            'rank' => $venue->getRank(),
        ], Response::HTTP_CREATED);
    }

    #[Route('/{uuid}', name: 'venue_update', methods: ['PUT'])]
    #[OA\Put(
        summary: 'Met à jour un venue existant',
        parameters: [
            new OA\Parameter(
                name: 'uuid',
                in: 'path',
                required: true,
                schema: new OA\Schema(type: 'string')
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: 'name', type: 'string', maxLength: 50),
                    new OA\Property(property: 'description', type: 'string', maxLength: 200, nullable: true),
                    new OA\Property(property: 'type', type: 'integer', nullable: true),
                    new OA\Property(property: 'rank', type: 'integer', nullable: true),
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Venue mis à jour avec succès',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'id', type: 'integer'),
                        new OA\Property(property: 'uuid', type: 'string'),
                        new OA\Property(property: 'name', type: 'string'),
                        new OA\Property(property: 'description', type: 'string', nullable: true),
                        new OA\Property(property: 'type', type: 'integer', nullable: true),
                        new OA\Property(property: 'rank', type: 'integer', nullable: true),
                    ]
                )
            ),
            new OA\Response(response: 404, description: 'Venue non trouvé'),
            new OA\Response(response: 400, description: 'Données invalides')
        ]
    )]
    public function update(string $uuid, Request $request): JsonResponse
    {
        $venue = $this->venueRepository->findByUuid($uuid);

        if (!$venue) {
            return $this->json(['error' => 'Venue non trouvé'], Response::HTTP_NOT_FOUND);
        }

        $data = json_decode($request->getContent(), true);

        if (isset($data['name']) && !empty($data['name'])) {
            $venue->setName($data['name']);
        }

        if (array_key_exists('description', $data)) {
            $venue->setDescription($data['description']);
        }

        if (array_key_exists('type', $data)) {
            $venue->setType($data['type'] !== null ? (int) $data['type'] : null);
        }

        if (array_key_exists('rank', $data)) {
            $venue->setRank($data['rank'] !== null ? (int) $data['rank'] : null);
        }

        $errors = $this->validator->validate($venue);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_BAD_REQUEST);
        }

        $this->venueRepository->save($venue);

        return $this->json([
            'id' => $venue->getId(),
            'uuid' => $venue->getUuid(),
            'name' => $venue->getName(),
            'description' => $venue->getDescription(),
            'type' => $venue->getType(),
            'rank' => $venue->getRank(),
        ]);
    }

    #[Route('/{uuid}', name: 'venue_delete', methods: ['DELETE'])]
    #[OA\Delete(
        summary: 'Supprime un venue',
        parameters: [
            new OA\Parameter(
                name: 'uuid',
                in: 'path',
                required: true,
                schema: new OA\Schema(type: 'string')
            )
        ],
        responses: [
            new OA\Response(response: 204, description: 'Venue supprimé avec succès'),
            new OA\Response(response: 404, description: 'Venue non trouvé')
        ]
    )]
    public function delete(string $uuid): JsonResponse
    {
        $venue = $this->venueRepository->findByUuid($uuid);

        if (!$venue) {
            return $this->json(['error' => 'Venue non trouvé'], Response::HTTP_NOT_FOUND);
        }

        $this->venueRepository->delete($venue);

        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/type/{type}', name: 'venue_by_type', methods: ['GET'])]
    #[OA\Get(
        summary: 'Récupère les venues par type',
        parameters: [
            new OA\Parameter(
                name: 'type',
                in: 'path',
                required: true,
                schema: new OA\Schema(type: 'integer')
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Liste des venues du type spécifié',
                content: new OA\JsonContent(
                    type: 'array',
                    items: new OA\Items(
                        properties: [
                            new OA\Property(property: 'id', type: 'integer'),
                            new OA\Property(property: 'uuid', type: 'string'),
                            new OA\Property(property: 'name', type: 'string'),
                            new OA\Property(property: 'description', type: 'string', nullable: true),
                            new OA\Property(property: 'type', type: 'integer', nullable: true),
                            new OA\Property(property: 'rank', type: 'integer', nullable: true),
                        ]
                    )
                )
            )
        ]
    )]
    public function getByType(int $type): JsonResponse
    {
        $venues = $this->venueRepository->findByType($type);

        $items = array_map(function (VenueEntity $venue) {
            return [
                'id' => $venue->getId(),
                'uuid' => $venue->getUuid(),
                'name' => $venue->getName(),
                'description' => $venue->getDescription(),
                'type' => $venue->getType(),
                'rank' => $venue->getRank(),
            ];
        }, $venues);

        return $this->json($items);
    }

    #[Route('/top/{limit}', name: 'venue_top', methods: ['GET'])]
    #[OA\Get(
        summary: 'Récupère les venues les mieux classées',
        parameters: [
            new OA\Parameter(
                name: 'limit',
                in: 'path',
                description: 'Nombre maximum de venues à retourner',
                schema: new OA\Schema(type: 'integer', default: 10)
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Liste des meilleurs venues',
                content: new OA\JsonContent(
                    type: 'array',
                    items: new OA\Items(
                        properties: [
                            new OA\Property(property: 'id', type: 'integer'),
                            new OA\Property(property: 'uuid', type: 'string'),
                            new OA\Property(property: 'name', type: 'string'),
                            new OA\Property(property: 'description', type: 'string', nullable: true),
                            new OA\Property(property: 'type', type: 'integer', nullable: true),
                            new OA\Property(property: 'rank', type: 'integer', nullable: true),
                        ]
                    )
                )
            )
        ]
    )]
    public function getTop(int $limit = 10): JsonResponse
    {
        $limit = min(50, max(1, $limit));
        $venues = $this->venueRepository->findTopRated($limit);

        $items = array_map(function (VenueEntity $venue) {
            return [
                'id' => $venue->getId(),
                'uuid' => $venue->getUuid(),
                'name' => $venue->getName(),
                'description' => $venue->getDescription(),
                'type' => $venue->getType(),
                'rank' => $venue->getRank(),
            ];
        }, $venues);

        return $this->json($items);
    }
}
