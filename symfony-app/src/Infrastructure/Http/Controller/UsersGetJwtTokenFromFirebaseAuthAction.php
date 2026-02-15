<?php

declare(strict_types=1);

namespace App\Infrastructure\Http\Controller;

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
    public function __construct(private readonly QueryBusInterface $queryBus)
    {
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
            if ('' == $userDTO->email) {
                $jwt = $this->queryBus->execute(new GetJwtForSignupQuery($userDTO));
            } else {
                $jwt = $this->queryBus->execute(new GetJwtFromUserQuery($userDTO));
            }

            return new JsonResponse([
                'jwt' => $jwt,
                'found' => ('' != $userDTO->email),
                'auth_uid' => $userDTO->authUid,
            ]);
        }





    }
}
