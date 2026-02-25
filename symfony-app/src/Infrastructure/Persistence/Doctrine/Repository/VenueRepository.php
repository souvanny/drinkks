<?php
// src/Infrastructure/Persistence/Doctrine/Repository/VenueRepository.php

namespace App\Infrastructure\Persistence\Doctrine\Repository;

use App\Infrastructure\Persistence\Doctrine\Entity\VenueEntity;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<VenueEntity>
 */
class VenueRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, VenueEntity::class);
    }

    public function save(VenueEntity $venue): void
    {
        $this->getEntityManager()->persist($venue);
        $this->getEntityManager()->flush();
    }

    public function delete(VenueEntity $venue): void
    {
        $this->getEntityManager()->remove($venue);
        $this->getEntityManager()->flush();
    }

    public function findByUuid(string $uuid): ?VenueEntity
    {
        return $this->findOneBy(['uuid' => $uuid]);
    }

    /**
     * Récupère toutes les venues avec filtres optionnels
     *
     * @param string|null $search Terme de recherche optionnel
     * @param int|null $type Filtre par type optionnel
     * @return VenueEntity[]
     */
    public function findAllWithFilters(?string $search = null, ?int $type = null): array
    {
        $qb = $this->createQueryBuilder('v')
            ->orderBy('v.rank', 'ASC')
            ->addOrderBy('v.name', 'ASC');

        if ($search !== null && !empty($search)) {
            $qb->andWhere('v.name LIKE :search OR v.description LIKE :search')
                ->setParameter('search', '%' . $search . '%');
        }

        if ($type !== null) {
            $qb->andWhere('v.type = :type')
                ->setParameter('type', $type);
        }

        return $qb->getQuery()->getResult();
    }

    /**
     * Récupère les venues par type
     */
    public function findByType(int $type): array
    {
        return $this->findBy(['type' => $type], ['rank' => 'ASC', 'name' => 'ASC']);
    }

    /**
     * Récupère les venues les mieux classées
     */
    public function findTopRated(int $limit = 10): array
    {
        return $this->findBy([], ['rank' => 'ASC', 'name' => 'ASC'], $limit);
    }
}
