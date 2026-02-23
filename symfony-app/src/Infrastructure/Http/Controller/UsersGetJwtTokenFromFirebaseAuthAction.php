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
use Lcobucci\JWT\Encoding\JoseEncoder;
use Lcobucci\JWT\Token\Parser;
use Lcobucci\JWT\Token\Plain;
use OpenApi\Attributes as OA;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Uid\Uuid;

#[Route('/api/users/jwt-by-firebase-token', name: 'UsersGetJwtTokenFromFirebaseAuth', methods: ['POST'])]
class UsersGetJwtTokenFromFirebaseAuthAction
{
    public function __construct(
        private readonly QueryBusInterface $queryBus,
        private readonly RefreshTokenService $refreshTokenService,
        private readonly UserRepository $userRepository,
        private readonly UserPasswordHasherInterface $passwordHasher
    ) {
    }

    #[OA\Tag(name: 'users')]
    public function __invoke(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        $token = $data['token'];

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
            $userEntity = null;

            if ('' == $userDTO->email) {
                // Nouvel utilisateur - le créer à partir du token Firebase
                $userEntity = $this->createUserFromFirebaseToken($token);

                // Sauvegarder l'utilisateur
                $this->userRepository->getEntityManager()->persist($userEntity);
                $this->userRepository->getEntityManager()->flush();

                // Re-créer le UserDTO avec les nouvelles informations
                $userDTO = UserDTO::fromEntity($userEntity);

                // Générer le JWT pour le nouvel utilisateur
                $jwtToken = $this->queryBus->execute(new GetJwtFromUserQuery($userDTO));
            } else {
                // Utilisateur existant - générer JWT normal
                $jwtToken = $this->queryBus->execute(new GetJwtFromUserQuery($userDTO));

                // Récupérer l'entité utilisateur pour générer le refresh token
                $userEntity = $this->getUserEntityByAuthUid($userDTO->authUid);
            }

            // Générer le refresh token si on a une entité utilisateur
            if ($userEntity) {
                // Révoquer tous les anciens refresh tokens (single session)
                $this->refreshTokenService->revokeAllUserTokens($userEntity);

                // Créer un nouveau refresh token
                $refreshTokenEntity = $this->refreshTokenService->createRefreshToken($userEntity);
                $refreshToken = $refreshTokenEntity->getRefreshToken();
            }

            $response = [
                'token' => $jwtToken,
                'found' => ('' != $userDTO->email),
                'auth_uid' => $userDTO->authUid,
            ];

            // Ajouter le refresh token
            if ($refreshToken) {
                $response['refresh_token'] = $refreshToken;
            }

            return new JsonResponse($response);
        }
    }

    /**
     * Crée un nouvel utilisateur à partir du token Firebase
     */
    private function createUserFromFirebaseToken(string $firebaseToken): UserEntity
    {
        // Parser le token Firebase pour extraire les informations
        $parser = new Parser(new JoseEncoder());
        /** @var Plain $token */
        $token = $parser->parse($firebaseToken);

        // Récupérer les claims
        $claims = $token->claims();

        // Extraire l'email et le sub (auth_uid)
        $email = $claims->get('email');
        $authUid = $claims->get('sub');

        if (!$email || !$authUid) {
            throw new \Exception('Email ou sub manquant dans le token Firebase');
        }

        // Générer un mot de passe fort aléatoire (l'utilisateur s'authentifiera via Firebase)
        $randomPassword = bin2hex(random_bytes(16)); // 32 caractères hexadécimaux

        // Créer la nouvelle entité
        $userEntity = new UserEntity();

        // Générer un UID unique pour l'utilisateur
        $userEntity->setUid(Uuid::v4()->toString());
        $userEntity->setAuthUid($authUid);
        $userEntity->setEmail($email);
        $userEntity->setUsername($email); // Utiliser l'email comme username par défaut
        $userEntity->setAboutMe('');
        $userEntity->setGender(0);
        $userEntity->setBirthdate(new \DateTime('today')); // 👈 Date du jour au lieu de null
        $userEntity->setStatus(1); // 1 = actif (valeur par défaut)
        $userEntity->setRoles(['ROLE_USER']);

        // Hasher le mot de passe aléatoire
        $hashedPassword = $this->passwordHasher->hashPassword($userEntity, $randomPassword);
        $userEntity->setPassword($hashedPassword);

        // Définir la date de création (sera aussi gérée par le PrePersist)
        $userEntity->setCreatedAt(new \DateTime());

        return $userEntity;
    }

    /**
     * Méthode utilitaire pour récupérer l'entité User à partir de l'authUid
     */
    private function getUserEntityByAuthUid(string $authUid): ?UserEntity
    {
        return $this->userRepository->findOneBy(['authUid' => $authUid]);
    }
}
