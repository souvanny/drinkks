<?php

namespace App\Infrastructure\Security;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Security\Http\Authenticator\AbstractAuthenticator;
use Symfony\Component\Security\Core\Exception\AuthenticationException;
use Symfony\Component\Security\Core\User\UserProviderInterface;
use Symfony\Component\Security\Http\Authenticator\Passport\SelfValidatingPassport;
use Symfony\Component\Security\Http\Authenticator\Passport\Badge\UserBadge;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;

class JwtAuthenticator extends AbstractAuthenticator
{
    private JWTTokenManagerInterface $jwtManager;
    private UserProviderInterface $userProvider;

    public function __construct(JWTTokenManagerInterface $jwtManager, UserProviderInterface $userProvider)
    {
        $this->jwtManager = $jwtManager;
        $this->userProvider = $userProvider;
    }

    public function supports(Request $request): ?bool
    {
        return $request->headers->has('Authorization');
    }

    public function authenticate(Request $request): SelfValidatingPassport
    {
        $authHeader = $request->headers->get('Authorization');
        if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
            throw new AuthenticationException('JWT Token not found');
        }

        $jwt = substr($authHeader, 7);

        try {
            $payload = $this->jwtManager->decodeFromJsonWebToken($jwt);
        } catch (\Exception $e) {
            throw new AuthenticationException('Invalid JWT Token');
        }

        $username = $payload['username'] ?? null;
        if (!$username) {
            throw new AuthenticationException('JWT Token invalid: username missing');
        }

        return new SelfValidatingPassport(
            new UserBadge($username, fn($userIdentifier) => $this->userProvider->loadUserByUsername($userIdentifier))
        );
    }

    public function onAuthenticationSuccess(Request $request, $token, string $firewallName): ?JsonResponse
    {
        // Laisser continuer la requête
        return null;
    }

    public function onAuthenticationFailure(Request $request, AuthenticationException $exception): ?JsonResponse
    {
        return new JsonResponse([
            'code' => 401,
            'message' => $exception->getMessage(),
        ], 401);
    }
}
