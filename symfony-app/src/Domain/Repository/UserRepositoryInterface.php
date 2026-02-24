<?php

namespace App\Domain\Repository;

use App\Domain\ValueObject\Email;
use App\Infrastructure\Persistence\Doctrine\Entity\UserEntity;

/**
 * Repository Interface (Port) - Contrat du domaine
 */
interface UserRepositoryInterface
{
    public function save(UserEntity $user): void;

    public function delete(UserEntity $user): void;

    public function findById(int $id): ?UserEntity;

    public function findByEmail(Email $email): ?UserEntity;

    /**
     * @return UserEntity[]
     */
    public function findAll(): array;

    /**
     * @return UserEntity[]
     */
    public function findActiveUsers(): array;

    /**
     * @return UserEntity[]
     */
    public function findByRole(string $role): array;

    /**
     * @return UserEntity[]
     */
    public function search(string $searchTerm): array;

    public function countActiveUsers(): int;

    public function existsByEmail(Email $email): bool;
}
