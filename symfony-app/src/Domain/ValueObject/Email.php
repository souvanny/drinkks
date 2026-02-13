<?php

namespace App\Domain\ValueObject;

/**
 * Value Object Email
 */
class Email
{
    private string $value;

    public function __construct(string $email)
    {
        $this->validate($email);
        $this->value = strtolower($email);
    }

    private function validate(string $email): void
    {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException(sprintf('"%s" is not a valid email', $email));
        }
    }

    public function getValue(): string
    {
        return $this->value;
    }

    public function __toString(): string
    {
        return $this->value;
    }

    public function equals(Email $other): bool
    {
        return $this->value === $other->value;
    }
}