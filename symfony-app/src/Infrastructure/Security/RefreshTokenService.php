<?php
// src/Infrastructure/Security/RefreshTokenService.php

namespace App\Infrastructure\Security;

use App\Infrastructure\Persistence\Doctrine\Entity\RefreshTokenEntity;
use App\Infrastructure\Persistence\Doctrine\Entity\UserEntity;
use App\Infrastructure\Persistence\Doctrine\Repository\RefreshTokenRepository;
use Symfony\Component\Security\Csrf\TokenGenerator\TokenGeneratorInterface;

class RefreshTokenService
{
    public function __construct(
        private readonly RefreshTokenRepository $refreshTokenRepository,
        private readonly TokenGeneratorInterface $tokenGenerator,
        private readonly int $ttl = 2592000 // 30 jours en secondes
    ) {}

    public function createRefreshToken(UserEntity $user): RefreshTokenEntity
    {
        // Optionnel: révoquer tous les anciens tokens pour cet utilisateur
        // $this->refreshTokenRepository->revokeAllForUser($user);

        $refreshToken = new RefreshTokenEntity();
        $refreshToken->setRefreshToken($this->tokenGenerator->generateToken());
        $refreshToken->setUser($user);
        $refreshToken->setValid(new \DateTime('+' . $this->ttl . ' seconds'));
        $refreshToken->setRevoked(false);

        $this->refreshTokenRepository->save($refreshToken);

        return $refreshToken;
    }

    public function validateRefreshToken(string $tokenString): ?RefreshTokenEntity
    {
        $refreshToken = $this->refreshTokenRepository->findByToken($tokenString);

        if (!$refreshToken || !$refreshToken->isValid()) {
            return null;
        }

        return $refreshToken;
    }

    public function revokeRefreshToken(string $tokenString): void
    {
        $refreshToken = $this->refreshTokenRepository->findByToken($tokenString);
        if ($refreshToken) {
            $refreshToken->setRevoked(true);
            $this->refreshTokenRepository->save($refreshToken);
        }
    }

    public function revokeAllUserTokens(UserEntity $user): void
    {
        $this->refreshTokenRepository->revokeAllForUser($user);
    }

    public function rotateRefreshToken(string $oldTokenString): ?RefreshTokenEntity
    {
        $oldToken = $this->validateRefreshToken($oldTokenString);
        if (!$oldToken) {
            return null;
        }

        // Révoquer l'ancien token
        $oldToken->setRevoked(true);
        $this->refreshTokenRepository->save($oldToken);

        // Créer un nouveau token
        return $this->createRefreshToken($oldToken->getUser());
    }
}
