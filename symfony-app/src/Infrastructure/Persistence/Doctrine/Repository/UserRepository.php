<?php

namespace App\Infrastructure\Persistence\Doctrine\Repository;

use App\Domain\Entity\User;
use App\Domain\Repository\UserRepositoryInterface;
use App\Domain\ValueObject\Email;
use App\Infrastructure\Persistence\Doctrine\Entity\UserEntity;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * Doctrine Repository (Adapter) - Implémente le port du domaine
 */
class UserRepository extends ServiceEntityRepository implements UserRepositoryInterface
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, UserEntity::class);
    }

    public function save(UserEntity $user): void
    {
        $userEntity = $this->toDoctrineEntity($user);

        $this->getEntityManager()->persist($userEntity);
        $this->getEntityManager()->flush();

        // Sync l'ID généré vers l'entité domain
        if ($user->getId() === null && $userEntity->getId() !== null) {
            $user->setId($userEntity->getId());
        }
    }

    public function delete(UserEntity $user): void
    {
        $userEntity = $this->find($user->getId());
        if ($userEntity) {
            $this->getEntityManager()->remove($userEntity);
            $this->getEntityManager()->flush();
        }
    }

    public function findById(int $id): ?UserEntity
    {
        $userEntity = $this->find($id);
        return $userEntity ? $this->toDomainEntity($userEntity) : null;
    }

    public function findByEmail(Email $email): ?UserEntity
    {
        $userEntity = $this->findOneBy(['email' => $email->getValue()]);
        return $userEntity ? $this->toDomainEntity($userEntity) : null;
    }

    public function findAll(): array
    {
        $entities = $this->findBy([], ['createdAt' => 'DESC']);
        return array_map(fn($e) => $this->toDomainEntity($e), $entities);
    }

    public function findActiveUsers(): array
    {
        $entities = $this->createQueryBuilder('u')
            ->where('u.isActive = :active')
            ->setParameter('active', true)
            ->orderBy('u.createdAt', 'DESC')
            ->getQuery()
            ->getResult();

        return array_map(fn($e) => $this->toDomainEntity($e), $entities);
    }

    public function findByRole(string $role): array
    {
        $entities = $this->createQueryBuilder('u')
            ->andWhere('JSON_CONTAINS(u.roles, :role) = 1')
            ->setParameter('role', json_encode($role))
            ->getQuery()
            ->getResult();

        return array_map(fn($e) => $this->toDomainEntity($e), $entities);
    }

    public function search(string $searchTerm): array
    {
        $entities = $this->createQueryBuilder('u')
            ->where('u.email LIKE :search OR u.firstname LIKE :search OR u.lastname LIKE :search')
            ->setParameter('search', '%' . $searchTerm . '%')
            ->orderBy('u.lastname', 'ASC')
            ->getQuery()
            ->getResult();

        return array_map(fn($e) => $this->toDomainEntity($e), $entities);
    }

    public function countActiveUsers(): int
    {
        return (int) $this->createQueryBuilder('u')
            ->select('COUNT(u.id)')
            ->where('u.isActive = :active')
            ->setParameter('active', true)
            ->getQuery()
            ->getSingleScalarResult();
    }

    public function existsByEmail(Email $email): bool
    {
        return $this->count(['email' => $email->getValue()]) > 0;
    }

    /**
     * Convertit une entité Domain en entité Doctrine
     */
    private function toDoctrineEntity(UserEntity $domainUser): UserEntity
    {
        $userEntity = new UserEntity();

        if ($domainUser->getId() !== null) {
            $existing = $this->find($domainUser->getId());
            if ($existing) {
                $userEntity = $existing;
            } else {
                $userEntity->setId($domainUser->getId());
            }
        }

        $userEntity->setEmail($domainUser->getEmail());
        $userEntity->setRoles($domainUser->getRoles());
        $userEntity->setPassword($domainUser->getPassword());
//        $userEntity->setFirstname($domainUser->getFirstname());
//        $userEntity->setLastname($domainUser->getLastname());
        $userEntity->setIsActive($domainUser->isActive());
        $userEntity->setCreatedAt($domainUser->getCreatedAt());

        if ($domainUser->getUpdatedAt()) {
            $userEntity->setUpdatedAt($domainUser->getUpdatedAt());
        }

        return $userEntity;
    }

    /**
     * Convertit une entité Doctrine en entité Domain
     */
    private function toDomainEntity(UserEntity $userEntity): UserEntity
    {
        $user = new UserEntity(
            new Email($userEntity->getEmail()),
            $userEntity->getPassword(),
//            $userEntity->getFirstname(),
//            $userEntity->getLastname()
        );

        $user->setId($userEntity->getId());

        // Restaurer les rôles (sans ROLE_USER par défaut qui sera ajouté automatiquement)
        $roles = array_filter($userEntity->getRoles(), fn($r) => $r !== 'ROLE_USER');
//        foreach ($roles as $role) {
//            $user->addRole($role);
//        }
        $user->setRoles($roles);

//        if (!$userEntity->isActive()) {
//            $user->deactivate();
//        }

        return $user;
    }

    public function getUserByAuthUid(string $firebaseAuthId): ?UserEntity
    {
        return $this->findOneBy(['authUid' => $firebaseAuthId]);
    }
}
