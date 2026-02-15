<?php

namespace App\Users\Application\Query\GetJwtFromUser;

use App\Shared\Application\Query\QueryInterface;
use App\Users\Application\DTO\UserDTO;

class GetJwtFromUserQuery implements QueryInterface
{
    public function __construct(
        public readonly UserDTO $user
    ) {
    }
}