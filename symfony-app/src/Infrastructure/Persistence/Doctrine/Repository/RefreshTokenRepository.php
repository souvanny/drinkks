<?php
// src/Infrastructure/Persistence/Doctrine/Repository/RefreshTokenRepository.php

namespace App\Infrastructure\Persistence\Doctrine\Repository;

use App\Infrastructure\Persistence\Doctrine\Entity\RefreshTokenEntity;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

class RefreshTokenRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, RefreshTokenEntity::class);
    }

    public function save(RefreshTokenEntity $refreshToken): void
    {
        $this->getEntityManager()->persist($refreshToken);
        $this->getEntityManager()->flush();
    }

    public function delete(RefreshTokenEntity $refreshToken): void
    {
        $this->getEntityManager()->remove($refreshToken);
        $this->getEntityManager()->flush();
    }

    public function findByToken(string $refreshToken): ?RefreshTokenEntity
    {
        return $this->findOneBy(['refreshToken' => $refreshToken]);
    }

    public function revokeAllForUser(UserEntity $user): void
    {
        $this->createQueryBuilder('rt')
            ->update()
            ->set('rt.revoked', ':revoked')
            ->where('rt.user = :user')
            ->setParameter('revoked', true)
            ->setParameter('user', $user)
            ->getQuery()
            ->execute();
    }

    public function deleteExpired(): int
    {
        return $this->createQueryBuilder('rt')
            ->delete()
            ->where('rt.valid < :now')
            ->setParameter('now', new \DateTime())
            ->getQuery()
            ->execute();
    }
}
