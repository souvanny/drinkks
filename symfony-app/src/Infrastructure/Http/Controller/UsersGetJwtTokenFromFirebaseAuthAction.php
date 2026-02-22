<?php

declare(strict_types=1);

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Persistence\Doctrine\Entity\UserEntity;
use App\Infrastructure\Persistence\Doctrine\Repository\UserRepository;
use App\Infrastructure\Security\RefreshTokenService;
use App\Shared\Application\Query\QueryBusInterface;
use App\Users\Application\Config\UsersAppConfig;
use App\Users\Application\DTO\UserDTO;
use App\Users\Application\Query\GetJwtForSignup\GetJwtForSignupQuery;
use App\Users\Application\Query\GetJwtFromUser\GetJwtFromUserQuery;
use App\Users\Application\Query\GetUserByFirebaseToken\GetUserByFirebaseTokenQuery;
use OpenApi\Attributes as OA;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/users/jwt-by-firebase-token', name: 'UsersGetJwtTokenFromFirebaseAuth', methods: ['POST'])]
class UsersGetJwtTokenFromFirebaseAuthAction
{
    public function __construct(
        private readonly QueryBusInterface $queryBus,
        private readonly RefreshTokenService $refreshTokenService,
        private readonly UserRepository $userRepository

    ) {
    }

    #[OA\Tag(name: 'users')]
    public function __invoke(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        $token = $data['token'];

//        die($token);

        /** @var UserDTO $userDTO */
        $userDTO = $this->queryBus->execute(new GetUserByFirebaseTokenQuery($token));

        if ($userDTO->status >= 20) {
            $message = '';
            switch($userDTO->status) {
                case UsersAppConfig::$USER_UNSUBSCRIBED:
                    $message = 'Vous êtes désinscrit(e).';
                    break;
                case UsersAppConfig::$USER_BANNED:
                    $message = 'Vous avez été banni(e).';
                    break;
                case UsersAppConfig::$USER_BLOCKED:
                    $message = 'Vous avez été bloqué(e).';
                    break;
            }

            return new JsonResponse(['message' => json_encode([
                "code" => UsersAppConfig::$ERREUR_USER,
                "title" => "Erreur",
                "message" => $message."\n\nSupport: contact@playwinher.com",
            ])], Response::HTTP_FORBIDDEN);
        } else {
            $refreshToken = null;

            if ('' == $userDTO->email) {
                // Nouvel utilisateur - générer JWT pour signup
                $jwtToken = $this->queryBus->execute(new GetJwtForSignupQuery($userDTO));
                // Pas de refresh token pour les utilisateurs en cours d'inscription
            } else {
                // Utilisateur existant - générer JWT normal
                $jwtToken = $this->queryBus->execute(new GetJwtFromUserQuery($userDTO));

                // Récupérer l'entité utilisateur pour générer le refresh token
                // Note: Vous aurez besoin d'un repository pour trouver l'utilisateur par authUid
                $userEntity = $this->getUserEntityByAuthUid($userDTO->authUid);

                $refreshToken = "AA : " . $userDTO->authUid;

                if ($userEntity) {
                    // Option 1: Révoquer tous les anciens refresh tokens (single session)
                    $this->refreshTokenService->revokeAllUserTokens($userEntity);

                    // Option 2: Garder l'ancien token (multi-session) - décommentez la ligne suivante
                    // $this->refreshTokenService->revokeAllUserTokens($userEntity);

                    // Créer un nouveau refresh token
                    $refreshTokenEntity = $this->refreshTokenService->createRefreshToken($userEntity);
                    $refreshToken = $refreshTokenEntity->getRefreshToken();
                }
            }

            $response = [
                'token' => $jwtToken,
                'found' => ('' != $userDTO->email),
                'auth_uid' => $userDTO->authUid,
            ];

            // Ajouter le refresh token seulement pour les utilisateurs existants
            if ($refreshToken) {
                $response['refresh_token'] = $refreshToken;
            }

            return new JsonResponse($response);
        }
    }

    /**
     * Méthode utilitaire pour récupérer l'entité User à partir de l'authUid
     * À adapter selon votre structure de repository
     */
    private function getUserEntityByAuthUid(string $authUid): ?UserEntity
    {
        // Implémentez cette méthode selon votre architecture
        // Par exemple, si vous avez un repository UserRepository:
        // return $this->userRepository->findOneBy(['authUid' => $authUid]);

        // Pour l'instant, on retourne null si pas implémenté
        // IMPORTANT: Vous devez injecter le repository approprié dans le constructeur
        return $this->userRepository->findOneBy(['authUid' => $authUid]);
    }
}
