<?php

namespace App\Infrastructure\Http\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'auth')]
class AuthController extends AbstractController
{
    public function __construct(
        private UserPasswordHasherInterface $passwordHasher
    ) {}

    #[Route('/api/auth/login', name: 'api_auth_login', methods: ['POST'])]
    #[OA\Post(
        summary: 'Authentifie un utilisateur et renvoie un JWT',
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: 'object',
                required: ['email', 'password'],
                properties: [
                    new OA\Property(property: 'email', type: 'string', example: 'user@example.com'),
                    new OA\Property(property: 'password', type: 'string', example: 'MonMotDePasse123!')
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Token JWT renvoyé',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'token', type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5...')
                    ]
                )
            ),
            new OA\Response(response: 401, description: 'Identifiants invalides')
        ]
    )]
    public function login(): void
    {
        // Lexik gère la logique, on ne met rien ici
    }

    #[Route('/api/auth/generate-password', name: 'api_auth_generate_password', methods: ['POST'])]
    #[OA\Post(
        summary: 'Hash un mot de passe en clair (utile pour tests ou création manuelle d’utilisateurs).',
        requestBody: new OA\RequestBody(
            required: true,
            description: 'Mot de passe à chiffrer',
            content: new OA\JsonContent(
                type: 'object',
                required: ['password'],
                properties: [
                    new OA\Property(property: 'password', type: 'string', example: 'MonMotDePasse123!')
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Mot de passe chiffré renvoyé avec succès',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'hash', type: 'string', example: '$2y$13$abc123...')
                    ]
                )
            )
        ]
    )]
    public function generatePassword(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        if (!isset($data['password']) || !is_string($data['password']) || $data['password'] === '') {
            return $this->json(['error' => 'Le champ "password" est requis.'], 400);
        }

        $plain = $data['password'];

        if (strlen($plain) < 8) {
            return $this->json(['error' => 'Le mot de passe doit faire au moins 8 caractères.'], 400);
        }

        // Fake user conforme à l’interface PasswordAuthenticatedUserInterface
        $user = new class implements PasswordAuthenticatedUserInterface {
            public function getPassword(): ?string { return null; }
        };

        $hash = $this->passwordHasher->hashPassword($user, $plain);

        return $this->json(['hash' => $hash]);
    }
}
