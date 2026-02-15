<?php

namespace App\Users\Application\Query\GetUserByFirebaseToken;

use App\Infrastructure\Persistence\Doctrine\Repository\UserRepository;
use App\Shared\Application\Query\QueryHandlerInterface;
use App\Users\Application\DTO\UserDTO;
use Lcobucci\JWT\Encoding\JoseEncoder;
use Lcobucci\JWT\Signer;
use Lcobucci\JWT\Signer\Rsa\Sha256;
use Lcobucci\JWT\Token\Parser;
use Lcobucci\JWT\Token\Plain;
use Lcobucci\JWT\Validation\Constraint\SignedWith;
use Lcobucci\JWT\Validation\Validator;

class GetUserByFirebaseTokenQueryHandler implements QueryHandlerInterface
{
    public function __construct(
        private readonly UserRepository $userRepository
    ) {
    }

    public function __invoke(GetUserByFirebaseTokenQuery $query): UserDTO
    {
        $firebaseToken = $query->token;

        $parser = new Parser(new JoseEncoder());

        /** @var Plain $token */
        $token = $parser->parse($firebaseToken);

        $kid = $token->headers()->get('kid');

        $googleJson = file_get_contents('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com');

        $jsonParsed = json_decode($googleJson, true);

        $privateKey = $jsonParsed[$kid];

        $signer = new Sha256();

        $validator = new Validator();

        $validator->assert($token, new SignedWith($signer, Signer\Key\InMemory::plainText($privateKey)));

        $firebaseAuthId = $token->claims()->get('user_id');

        $user = $this->userRepository->getUserByAuthUid($firebaseAuthId);

        if (null == $user) {
            return UserDTO::forSignupProcess($firebaseAuthId);
        }

        return UserDTO::fromEntity($user);
    }
}
