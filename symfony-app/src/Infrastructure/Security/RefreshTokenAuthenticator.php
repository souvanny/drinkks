<?php
// src/Infrastructure/Security/RefreshTokenAuthenticator.php

namespace App\Infrastructure\Security;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Security\Http\Authenticator\AbstractAuthenticator;
use Symfony\Component\Security\Core\Exception\AuthenticationException;
use Symfony\Component\Security\Core\User\UserProviderInterface;
use Symfony\Component\Security\Http\Authenticator\Passport\SelfValidatingPassport;
use Symfony\Component\Security\Http\Authenticator\Passport\Badge\UserBadge;

class RefreshTokenAuthenticator extends AbstractAuthenticator
{
    public function __construct(
        private RefreshTokenService $refreshTokenService,
        private UserProviderInterface $userProvider
    ) {}

    public function supports(Request $request): ?bool
    {
        return $request->getPathInfo() === '/api/auth/refresh' && $request->isMethod('POST');
    }

    public function authenticate(Request $request): SelfValidatingPassport
    {
        $data = json_decode($request->getContent(), true);
        $refreshTokenString = $data['refresh_token'] ?? null;

        if (!$refreshTokenString) {
            throw new AuthenticationException('Refresh token missing');
        }

        $refreshToken = $this->refreshTokenService->validateRefreshToken($refreshTokenString);

        if (!$refreshToken) {
            throw new AuthenticationException('Invalid refresh token');
        }

        $user = $refreshToken->getUser();

        return new SelfValidatingPassport(
            new UserBadge($user->getUserIdentifier(), fn() => $user)
        );
    }

    public function onAuthenticationSuccess(Request $request, $token, string $firewallName): ?JsonResponse
    {
        return null; // Continue la requête
    }

    public function onAuthenticationFailure(Request $request, AuthenticationException $exception): ?JsonResponse
    {
        return new JsonResponse([
            'error' => 'Refresh token invalide'
        ], 401);
    }
}
