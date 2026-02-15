<?php

namespace App\Users\Application\Query\GetUserByFirebaseToken;

use App\Shared\Application\Query\QueryInterface;

class GetUserByFirebaseTokenQuery implements QueryInterface
{
    public function __construct(
        public readonly string $token,
    ) {
    }
}