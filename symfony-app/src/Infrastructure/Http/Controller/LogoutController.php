<?php
// src/Infrastructure/Http/Controller/LogoutController.php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Security\RefreshTokenService;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/auth/logout', name: 'api_auth_logout', methods: ['POST'])]
#[OA\Tag(name: 'auth')]
class LogoutController extends AbstractController
{
    public function __construct(
        private readonly RefreshTokenService $refreshTokenService
    ) {}

    #[OA\Post(
        summary: 'Déconnecte l\'utilisateur',
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: 'object',
                required: ['refresh_token'],
                properties: [
                    new OA\Property(property: 'refresh_token', type: 'string', example: '550e8400-e29b-41d4-a716-446655440000')
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: 'Déconnexion réussie')
        ]
    )]
    public function __invoke(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        $refreshTokenString = $data['refresh_token'] ?? null;

        if ($refreshTokenString) {
            $this->refreshTokenService->revokeRefreshToken($refreshTokenString);
        }

        return $this->json(['message' => 'Déconnexion réussie']);
    }
}
