<?php

namespace App\Infrastructure\Persistence\Doctrine\Entity;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;

/**
 * Infrastructure Entity - Mapping Doctrine uniquement
 * Sert d'adapter entre le domaine et la base de données
 */
#[ORM\Entity]
#[ORM\Table(name: '`user`')]
#[ORM\HasLifecycleCallbacks]
class UserEntity implements UserInterface, PasswordAuthenticatedUserInterface
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 100, nullable: true)]
    private ?string $uid = null;

    #[ORM\Column(name: 'auth_uid', type: 'string', length: 100, nullable: true)]
    private ?string $authUid = null;

    #[ORM\Column(type: 'json')]
    private array $roles = [];

    #[ORM\Column(type: 'string', length: 100, nullable: true)]
    private ?string $email = null;

    #[ORM\Column(type: 'string', length: 100, nullable: true)]
    private ?string $username = null;

    // Champ displayName
    #[ORM\Column(type: 'string', length: 100, nullable: true)]
    private ?string $displayName = null;

    #[ORM\Column(type: 'string', length: 255)]
    private string $password;

    #[ORM\Column(name: 'about_me', type: 'text', nullable: true)]
    private ?string $aboutMe = null;

    #[ORM\Column(type: 'integer', nullable: true)]
    private ?int $gender = null;

    #[ORM\Column(type: 'date', nullable: true)]
    private ?\DateTime $birthdate = null;

    #[ORM\Column(type: 'integer', options: ['default' => 1])]
    private int $status = 1;

    // NOUVEAU: Champ pour indiquer si l'utilisateur a une photo
    // IMPORTANT: Initialisé à false dans la déclaration ET dans le constructeur
    #[ORM\Column(name: 'has_photo', type: 'boolean', options: ['default' => false])]
    private bool $hasPhoto = false;

    #[ORM\Column(name: 'created_at', type: 'datetime')]
    private \DateTimeInterface $createdAt;

    #[ORM\Column(name: 'updated_at', type: 'datetime', nullable: true)]
    private ?\DateTimeInterface $updatedAt = null;

    /**
     * Constructeur avec initialisation de toutes les propriétés
     */
    public function __construct()
    {
        $this->hasPhoto = false;
        $this->createdAt = new \DateTime();
    }

    #[ORM\PrePersist]
    public function setCreatedAtValue(): void
    {
        if ($this->createdAt === null) {
            $this->createdAt = new \DateTime();
        }
    }

    #[ORM\PreUpdate]
    public function setUpdatedAtValue(): void
    {
        $this->updatedAt = new \DateTime();
    }

    // Getters and Setters
    public function getId(): ?int
    {
        return $this->id;
    }

    public function setId(?int $id): void
    {
        $this->id = $id;
    }

    public function getUid(): ?string
    {
        return $this->uid;
    }

    public function setUid(?string $uid): void
    {
        $this->uid = $uid;
    }

    public function getAuthUid(): ?string
    {
        return $this->authUid;
    }

    public function setAuthUid(?string $authUid): void
    {
        $this->authUid = $authUid;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function setEmail(?string $email): void
    {
        $this->email = $email;
    }

    public function getUsername(): ?string
    {
        return $this->username;
    }

    public function setUsername(?string $username): void
    {
        $this->username = $username;
    }

    public function getDisplayName(): ?string
    {
        return $this->displayName;
    }

    public function setDisplayName(?string $displayName): void
    {
        $this->displayName = $displayName;
    }

    public function getAboutMe(): ?string
    {
        return $this->aboutMe;
    }

    public function setAboutMe(?string $aboutMe): void
    {
        $this->aboutMe = $aboutMe;
    }

    public function getGender(): ?int
    {
        return $this->gender;
    }

    public function setGender(?int $gender): void
    {
        $this->gender = $gender;
    }

    public function getBirthdate(): ?\DateTime
    {
        return $this->birthdate;
    }

    public function setBirthdate(?\DateTime $birthdate): void
    {
        $this->birthdate = $birthdate;
    }

    public function getStatus(): int
    {
        return $this->status;
    }

    public function setStatus(int $status): void
    {
        $this->status = $status;
    }

    // Getter/Setter pour hasPhoto
    public function hasPhoto(): bool
    {
        return $this->hasPhoto;
    }

    public function setHasPhoto(bool $hasPhoto): self
    {
        $this->hasPhoto = $hasPhoto;
        return $this;
    }

    // Méthode utilitaire pour mettre à jour le statut photo
    public function updatePhotoStatus(bool $hasPhoto): void
    {
        $this->hasPhoto = $hasPhoto;
        $this->updatedAt = new \DateTime();
    }

    public function getUserIdentifier(): string
    {
        return $this->email ?? '';
    }

    public function getRoles(): array
    {
        $roles = $this->roles;
        $roles[] = 'ROLE_USER';
        return array_unique($roles);
    }

    public function setRoles(array $roles): void
    {
        $this->roles = $roles;
    }

    public function getPassword(): string
    {
        return $this->password;
    }

    public function setPassword(string $password): void
    {
        $this->password = $password;
    }

    public function eraseCredentials(): void
    {
    }

    public function getCreatedAt(): \DateTimeInterface
    {
        return $this->createdAt;
    }

    public function setCreatedAt(\DateTimeInterface $createdAt): void
    {
        $this->createdAt = $createdAt;
    }

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeInterface $updatedAt): void
    {
        $this->updatedAt = $updatedAt;
    }

    /**
     * Méthodes d'aide pour la compatibilité avec l'ancien nommage
     */
    public function isActive(): bool
    {
        return $this->status === 1;
    }

    public function setIsActive(bool $isActive): void
    {
        $this->status = $isActive ? 1 : 0;
    }
}
