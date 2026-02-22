<?php
// src/Infrastructure/Http/Controller/RefreshTokenController.php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Security\RefreshTokenService;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/auth/refresh', name: 'api_auth_refresh', methods: ['POST'])]
#[OA\Tag(name: 'auth')]
class RefreshTokenController extends AbstractController
{
    public function __construct(
        private readonly RefreshTokenService $refreshTokenService,
        private readonly JWTTokenManagerInterface $jwtManager
    ) {}

    #[OA\Post(
        summary: 'Rafraîchit un token JWT expiré',
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['refresh_token'],
                properties: [
                    new OA\Property(property: 'refresh_token', type: 'string', example: '550e8400-e29b-41d4-a716-446655440000')
                ],
                type: 'object'
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Nouveau token JWT et nouveau refresh token',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'token', type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5...'),
                        new OA\Property(property: 'refresh_token', type: 'string', example: '550e8400-e29b-41d4-a716-446655440000')
                    ],
                    type: 'object'
                )
            ),
            new OA\Response(response: 401, description: 'Refresh token invalide')
        ]
    )]
    public function __invoke(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

//        echo "popipopipopipopipopipopipopipopi\n";
//        print_r($data);
//        exit;

        $refreshTokenString = $data['refresh_token'] ?? null;

        if (!$refreshTokenString) {
            return $this->json(['error' => 'Refresh token requis'], Response::HTTP_BAD_REQUEST);
        }

        // Rotation du refresh token (single use)
        $newRefreshToken = $this->refreshTokenService->rotateRefreshToken($refreshTokenString);

        if (!$newRefreshToken) {
            return $this->json(['error' => 'Refresh token invalide ou expiré'], Response::HTTP_UNAUTHORIZED);
        }

        // Générer un nouveau JWT
        $user = $newRefreshToken->getUser();
        $newJwt = $this->jwtManager->create($user);

        return $this->json([
            'token' => $newJwt,
            'refresh_token' => $newRefreshToken->getRefreshToken()
        ]);
    }
}
