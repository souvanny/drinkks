<?php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Persistence\Doctrine\Entity\UserEntity;
use App\Infrastructure\Persistence\Doctrine\Repository\UserRepository;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\CurrentUser;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;

#[Route('/api/account')]
#[OA\Tag(name: 'account')]
class AccountController extends AbstractController
{
    public function __construct(
        private readonly UserRepository $userRepository,
        private readonly SerializerInterface $serializer,
        private readonly ValidatorInterface $validator,
    ) {}

    #[Route('/me', name: 'account_get_me', methods: ['GET'])]
    #[OA\Get(
        summary: 'Récupère les informations du compte',
        responses: [
            new OA\Response(
                response: 200,
                description: 'Informations du compte',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'id', type: 'string'),
                        new OA\Property(property: 'username', type: 'string', nullable: true),
                        new OA\Property(property: 'gender', type: 'integer', nullable: true),
                        new OA\Property(property: 'birthdate', type: 'string', format: 'date', nullable: true),
                    ]
                )
            )
        ]
    )]
    public function getMe(#[CurrentUser] UserEntity $user): JsonResponse
    {
        return $this->json([
            'id' => $user->getEmail() ?? $user->getAuthUid(),
            'username' => $user->getUsername(),
            'gender' => $user->getGender(),
            'birthdate' => $user->getBirthdate()?->format('Y-m-d'),
        ]);
    }

    #[Route('/me', name: 'account_update_me', methods: ['PUT'])]
    #[OA\Put(
        summary: 'Met à jour les informations du compte',
        requestBody: new OA\RequestBody(
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: 'username', type: 'string', nullable: true),
                    new OA\Property(property: 'gender', type: 'integer', nullable: true),
                    new OA\Property(property: 'birthdate', type: 'string', format: 'date', nullable: true),
                ]
            )
        )
    )]
    public function updateMe(Request $request, #[CurrentUser] UserEntity $user): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        if (isset($data['username'])) {
            $user->setUsername($data['username']);
        }

        if (isset($data['gender'])) {
            $user->setGender((int) $data['gender']);
        }

        if (isset($data['birthdate'])) {
            try {
                $user->setBirthdate(new \DateTime($data['birthdate']));
            } catch (\Exception $e) {
                return $this->json(['error' => 'Format de date invalide'], Response::HTTP_BAD_REQUEST);
            }
        }

        $errors = $this->validator->validate($user);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_BAD_REQUEST);
        }

        $this->userRepository->save($user);

        return $this->json(['success' => true]);
    }

    #[Route('/about-me', name: 'account_get_about_me', methods: ['GET'])]
    public function getAboutMe(#[CurrentUser] UserEntity $user): JsonResponse
    {
        return $this->json([
            'about_me' => $user->getAboutMe(),
        ]);
    }

    #[Route('/about-me', name: 'account_update_about_me', methods: ['PUT'])]
    public function updateAboutMe(Request $request, #[CurrentUser] UserEntity $user): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        if (isset($data['about_me'])) {
            $user->setAboutMe($data['about_me']);
            $this->userRepository->save($user);
        }

        return $this->json(['success' => true]);
    }

    #[Route('/photo', name: 'account_get_photo', methods: ['GET'])]
    public function getPhoto(#[CurrentUser] UserEntity $user): JsonResponse
    {
        // Pour l'instant, on retourne une URL par défaut
        // À implémenter avec un système de stockage (S3, etc.)
        return $this->json([
            'photo_url' => null,
        ]);
    }

    #[Route('/photo', name: 'account_update_photo', methods: ['PUT'])]
    public function updatePhoto(Request $request, #[CurrentUser] UserEntity $user): JsonResponse
    {
        $photo = $request->files->get('photo');

        if (!$photo) {
            return $this->json(['error' => 'Aucune photo fournie'], Response::HTTP_BAD_REQUEST);
        }

        // TODO: Upload vers un service de stockage (S3, etc.)
        // Pour l'exemple, on simule le succès

        return $this->json(['success' => true]);
    }
}
