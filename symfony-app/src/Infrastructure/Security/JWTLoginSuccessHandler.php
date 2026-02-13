<?php

namespace App\Infrastructure\Security;

use App\Infrastructure\Persistence\Doctrine\Entity\UserEntity;
use Lexik\Bundle\JWTAuthenticationBundle\Event\AuthenticationSuccessEvent;
use Lexik\Bundle\JWTAuthenticationBundle\Events;
use Lexik\Bundle\JWTAuthenticationBundle\Response\JWTAuthenticationSuccessResponse;
use Lexik\Bundle\JWTAuthenticationBundle\Security\Http\Cookie\JWTCookieProvider;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Security\Http\Authentication\AuthenticationSuccessHandlerInterface;
use Symfony\Contracts\EventDispatcher\EventDispatcherInterface;

class JWTLoginSuccessHandler implements AuthenticationSuccessHandlerInterface
{
    public function __construct(
        protected JWTTokenManagerInterface $jwtManager,
        protected EventDispatcherInterface $dispatcher,
        iterable $cookieProviders = [],
        bool $removeTokenFromBodyWhenCookiesUsed = true
    ) {
        $this->jwtManager = $jwtManager;
        $this->dispatcher = $dispatcher;
        $this->cookieProviders = $cookieProviders;
        $this->removeTokenFromBodyWhenCookiesUsed = $removeTokenFromBodyWhenCookiesUsed;
    }

    /**
     * {@inheritdoc}
     */
    public function onAuthenticationSuccess(Request $request, TokenInterface $token): Response
    {
        return $this->handleAuthenticationSuccess($token->getUser());
    }

    public function handleAuthenticationSuccess(UserInterface $user, $jwt = null)
    {
        if (null === $jwt) {
            $jwt = $this->jwtManager->create($user);
        }

        $jwtCookies = [];
        foreach ($this->cookieProviders as $cookieProvider) {
            $jwtCookies[] = $cookieProvider->createCookie($jwt);
        }


        $responseData = [
            'token' => $jwt,
            'user' => [
                'email' => $user->getUserIdentifier(),
                'roles' => $user->getRoles(),
                'firstname' => method_exists($user, 'getFirstname') ? $user->getFirstname() : null,
                'lastname' => method_exists($user, 'getLastname') ? $user->getLastname() : null,
            ],
        ];

        $event = new AuthenticationSuccessEvent($responseData, $user, new JWTAuthenticationSuccessResponse($jwt, [], $jwtCookies));
        $this->dispatcher->dispatch($event, Events::AUTHENTICATION_SUCCESS);

        $response = new JWTAuthenticationSuccessResponse($jwt, [], $jwtCookies);
        $response->setData($event->getData());

        if ($jwtCookies && $this->removeTokenFromBodyWhenCookiesUsed) {
            unset($responseData['token']);
        }

        return $response;
    }

}
