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
     * Récupère la liste des venues avec pagination
     *
     * @param int $page Numéro de page (commence à 1)
     * @param int $limit Nombre d'éléments par page
     * @param string|null $search Terme de recherche optionnel
     * @param int|null $type Filtre par type optionnel
     * @return array{items: VenueEntity[], total: int, page: int, limit: int, pages: int}
     */
    public function findPaginated(int $page = 1, int $limit = 20, ?string $search = null, ?int $type = null): array
    {
        $qb = $this->createQueryBuilder('v')
            ->orderBy('v.rank', 'DESC')
            ->addOrderBy('v.name', 'ASC');

        // Appliquer les filtres
        if ($search !== null && !empty($search)) {
            $qb->andWhere('v.name LIKE :search OR v.description LIKE :search')
                ->setParameter('search', '%' . $search . '%');
        }

        if ($type !== null) {
            $qb->andWhere('v.type = :type')
                ->setParameter('type', $type);
        }

        // Compter le total
        $countQb = clone $qb;
        $total = (int) $countQb->select('COUNT(v.id)')
            ->getQuery()
            ->getSingleScalarResult();

        // Pagination
        $offset = ($page - 1) * $limit;
        $qb->setFirstResult($offset)
            ->setMaxResults($limit);

        $items = $qb->getQuery()->getResult();

        $pages = (int) ceil($total / $limit);

        return [
            'items' => $items,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'pages' => $pages
        ];
    }

    /**
     * Récupère les venues par type
     */
    public function findByType(int $type): array
    {
        return $this->findBy(['type' => $type], ['rank' => 'DESC', 'name' => 'ASC']);
    }

    /**
     * Récupère les venues les mieux classées
     */
    public function findTopRated(int $limit = 10): array
    {
        return $this->findBy([], ['rank' => 'DESC', 'name' => 'ASC'], $limit);
    }
}
