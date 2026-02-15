<?php

declare(strict_types=1);

namespace App\Users\Application\DTO;

use App\Infrastructure\Persistence\Doctrine\Entity\UserEntity;
use App\Users\Domain\Entity\User;

class UserDTO
{
    public function __construct(
        public readonly ?int $id,
        public readonly string $uid,
        public readonly string $authUid,
        public readonly string $email,
        public readonly string $username = '',
        public readonly string $aboutMe = '',
        public readonly int $gender = 0,
        public readonly \DateTime $birthdate = new \DateTime(),
        public readonly int $status = 0,
    ) {
    }

    public static function fromEntity(UserEntity $user): self
    {
        return new self(
            $user->getId(),
            $user->getUid(),
            $user->getAuthUid(),
            $user->getEmail(),
            $user->getUsername(),
            $user->getAboutMe(),
            $user->getGender(),
            $user->getBirthdate(),
            $user->getStatus(),
        );
    }
    public static function fromArray(array $user): self
    {
        $birthdate = \DateTime::createFromFormat("Y-m-d", $user['birthdate']);

        return new self(
            $user['id'],
            $user['uid'],
            $user['auth_uid'],
            $user['email'],
            $user['username'],
            $user['about_me'],
            $user['gender'],
            $birthdate,
            $user['status'],
        );
    }

    public static function forSignupProcess(string $authUid): self
    {
        return new self(null, '', $authUid, '');
    }
}
