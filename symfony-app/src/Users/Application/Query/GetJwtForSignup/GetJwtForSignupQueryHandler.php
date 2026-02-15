<?php

namespace App\Users\Application\Query\GetJwtForSignup;

use App\Infrastructure\Persistence\Doctrine\Repository\UserRepository;
use App\Shared\Application\Query\QueryHandlerInterface;
use App\Users\Application\DTO\UserDTO;
//use App\Users\Domain\Repository\UserRepositoryInterface;
use Lcobucci\JWT\Encoding\ChainedFormatter;
use Lcobucci\JWT\Encoding\JoseEncoder;
use Lcobucci\JWT\Signer\Key\InMemory;
use Lcobucci\JWT\Signer\Hmac\Sha512;
use Lcobucci\JWT\Token\Builder;

class GetJwtForSignupQueryHandler implements QueryHandlerInterface
{
    public function __construct(
        private readonly UserRepository $userRepository
    ) {
    }

    public function __invoke(GetJwtForSignupQuery $query): string
    {
        $userDto = $query->userDto;

        $authUid = $userDto->authUid;
        $email = $userDto->email;

        $tokenBuilder = (new Builder(new JoseEncoder(), ChainedFormatter::default()));
        $algorithm = new Sha512();
        $signinKey = InMemory::file(__DIR__.'/../../../../../config/jwt/private.pem');

        $now = new \DateTimeImmutable();

        $token = $tokenBuilder
//            ->issuedBy('http://example.com')
//            ->permittedFor('http://example.org')
//            ->relatedTo('component1')
//            ->identifiedBy('4f1g23a12aa')
//            ->issuedAt($now)
//            ->canOnlyBeUsedAfter($now->modify('+1 minute'))
            ->expiresAt($now->modify('+1 hour'))
            ->withClaim('authUid', $authUid)
            ->withClaim('email', $email)
            ->withClaim('username', $email)
            ->getToken($algorithm, $signinKey);

        return $token->toString();
    }
}
