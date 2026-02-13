<?php

namespace App\Domain\Repository;

use App\Domain\Entity\User;
use App\Domain\ValueObject\Email;

/**
 * Repository Interface (Port) - Contrat du domaine
 */
interface UserRepositoryInterface
{
    public function save(User $user): void;

    public function delete(User $user): void;

    public function findById(int $id): ?User;

    public function findByEmail(Email $email): ?User;

    /**
     * @return User[]
     */
    public function findAll(): array;

    /**
     * @return User[]
     */
    public function findActiveUsers(): array;

    /**
     * @return User[]
     */
    public function findByRole(string $role): array;

    /**
     * @return User[]
     */
    public function search(string $searchTerm): array;

    public function countActiveUsers(): int;

    public function existsByEmail(Email $email): bool;
}