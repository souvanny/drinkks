<?php
namespace App\Domain\ValueObject;

class UserRole
{
    public const ROLE_USER = 'ROLE_USER';
    public const ROLE_ADMIN = 'ROLE_ADMIN';
    public const ROLE_MODERATOR = 'ROLE_MODERATOR';

    private const VALID_ROLES = [
        self::ROLE_USER,
        self::ROLE_ADMIN,
        self::ROLE_MODERATOR,
    ];

    public static function isValid(string $role): bool
    {
        return in_array($role, self::VALID_ROLES);
    }

    public static function validate(string $role): void
    {
        if (!self::isValid($role)) {
            throw new \InvalidArgumentException(sprintf('Invalid role: %s', $role));
        }
    }
}