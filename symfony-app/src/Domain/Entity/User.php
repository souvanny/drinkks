<?php

namespace App\Domain\Entity;

use App\Domain\ValueObject\Email;
use App\Domain\ValueObject\UserRole;

/**
 * Domain Entity - Aucune dépendance vers Doctrine ou Symfony
 */
class User
{
    private ?int $id = null;
    private Email $email;
    private array $roles = [];
    private string $password;
    private ?string $firstname = null;
    private ?string $lastname = null;
    private bool $isActive = true;
    private \DateTimeInterface $createdAt;
    private ?\DateTimeInterface $updatedAt = null;

    public function __construct(
        Email $email,
        string $hashedPassword,
        ?string $firstname = null,
        ?string $lastname = null
    ) {
        $this->email = $email;
        $this->password = $hashedPassword;
        $this->firstname = $firstname;
        $this->lastname = $lastname;
        $this->roles = [UserRole::ROLE_USER];
        $this->createdAt = new \DateTime();
    }

    public static function create(
        string $email,
        string $hashedPassword,
        ?string $firstname = null,
        ?string $lastname = null
    ): self {
        return new self(
            new Email($email),
            $hashedPassword,
            $firstname,
            $lastname
        );
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function setId(int $id): void
    {
        $this->id = $id;
    }

    public function getEmail(): Email
    {
        return $this->email;
    }

    public function changeEmail(Email $email): void
    {
        $this->email = $email;
        $this->markAsUpdated();
    }

    public function getRoles(): array
    {
        return array_unique($this->roles);
    }

    public function addRole(string $role): void
    {
        if (!in_array($role, $this->roles)) {
            $this->roles[] = $role;
            $this->markAsUpdated();
        }
    }

    public function removeRole(string $role): void
    {
        $this->roles = array_filter($this->roles, fn($r) => $r !== $role);
        $this->markAsUpdated();
    }

    public function hasRole(string $role): bool
    {
        return in_array($role, $this->roles);
    }

    public function getPassword(): string
    {
        return $this->password;
    }

    public function changePassword(string $hashedPassword): void
    {
        $this->password = $hashedPassword;
        $this->markAsUpdated();
    }

    public function getFirstname(): ?string
    {
        return $this->firstname;
    }

    public function setFirstname(?string $firstname): void
    {
        $this->firstname = $firstname;
        $this->markAsUpdated();
    }

    public function getLastname(): ?string
    {
        return $this->lastname;
    }

    public function setLastname(?string $lastname): void
    {
        $this->lastname = $lastname;
        $this->markAsUpdated();
    }

    public function getFullName(): string
    {
        return trim(($this->firstname ?? '') . ' ' . ($this->lastname ?? ''));
    }

    public function isActive(): bool
    {
        return $this->isActive;
    }

    public function activate(): void
    {
        $this->isActive = true;
        $this->markAsUpdated();
    }

    public function deactivate(): void
    {
        $this->isActive = false;
        $this->markAsUpdated();
    }

    public function getCreatedAt(): \DateTimeInterface
    {
        return $this->createdAt;
    }

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updatedAt;
    }

    private function markAsUpdated(): void
    {
        $this->updatedAt = new \DateTime();
    }
}