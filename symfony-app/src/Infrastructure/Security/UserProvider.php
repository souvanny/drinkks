<?php

namespace App\Infrastructure\Security;

use App\Infrastructure\Persistence\Doctrine\Repository\UserRepository;
use Symfony\Component\Security\Core\Exception\UnsupportedUserException;
use Symfony\Component\Security\Core\Exception\UserNotFoundException;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\PasswordUpgraderInterface;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Security\Core\User\UserProviderInterface;

/**
 * UserProvider adapté à l'architecture hexagonale
 */
class UserProvider implements UserProviderInterface, PasswordUpgraderInterface
{
    public function __construct(
        private readonly UserRepository $userRepository
    ) {}

    public function refreshUser(UserInterface $user): UserInterface
    {
        if (!$user instanceof \App\Infrastructure\Persistence\Doctrine\Entity\UserEntity) {
            throw new UnsupportedUserException(sprintf('Invalid user class "%s".', $user::class));
        }

        $freshUser = $this->userRepository->find($user->getId());

        if (!$freshUser) {
            throw new UserNotFoundException();
        }

        return $freshUser;
    }

    public function supportsClass(string $class): bool
    {
        return \App\Infrastructure\Persistence\Doctrine\Entity\UserEntity::class === $class
            || is_subclass_of($class, \App\Infrastructure\Persistence\Doctrine\Entity\UserEntity::class);
    }

    public function loadUserByIdentifier(string $identifier): UserInterface
    {
        $user = $this->userRepository->findOneBy(['email' => $identifier]);

        if (!$user) {
            throw new UserNotFoundException(sprintf('User "%s" not found.', $identifier));
        }

        return $user;
    }

    public function upgradePassword(PasswordAuthenticatedUserInterface $user, string $newHashedPassword): void
    {
        if (!$user instanceof \App\Infrastructure\Persistence\Doctrine\Entity\UserEntity) {
            throw new UnsupportedUserException(sprintf('Invalid user class "%s".', $user::class));
        }

        $user->setPassword($newHashedPassword);
        $this->userRepository->getEntityManager()->persist($user);
        $this->userRepository->getEntityManager()->flush();
    }
}