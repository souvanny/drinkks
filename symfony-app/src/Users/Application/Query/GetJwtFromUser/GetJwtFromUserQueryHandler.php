<?php

namespace App\Users\Application\Query\GetJwtFromUser;

use App\Shared\Application\Query\QueryHandlerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;

class GetJwtFromUserQueryHandler implements QueryHandlerInterface
{
    public function __construct(
        private readonly JWTEncoderInterface $encoder
    ) {
    }

    public function __invoke(GetJwtFromUserQuery $query): string
    {
        return $this->encoder->encode(
            [
                'roles' => [
                    'ROLE_USER',
                ],
                'email' => $query->user->email,
                'username' => $query->user->email,
                'uid' => $query->user->authUid,
            ]
        );
    }
}
