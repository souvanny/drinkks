<?php

namespace App\Users\Application\Query\GetJwtForSignup;

use App\Shared\Application\Query\QueryInterface;
use App\Users\Application\DTO\UserDTO;

class GetJwtForSignupQuery implements QueryInterface
{
    public function __construct(
        public readonly UserDTO $userDto
    ) {
    }
}