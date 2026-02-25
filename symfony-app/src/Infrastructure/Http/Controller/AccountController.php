<?php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Persistence\Doctrine\Entity\UserEntity;
use App\Infrastructure\Persistence\Doctrine\Repository\UserRepository;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\File\UploadedFile;
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
    private const PHOTO_UPLOAD_DIR = '/upload/photos';
    private const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    private const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

    public function __construct(
        private readonly UserRepository $userRepository,
        private readonly SerializerInterface $serializer,
        private readonly ValidatorInterface $validator,
        private readonly string $projectDir,
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
                        new OA\Property(property: 'displayName', type: 'string', nullable: true),
                        new OA\Property(property: 'gender', type: 'integer', nullable: true),
                        new OA\Property(property: 'birthdate', type: 'string', format: 'date', nullable: true),
                        new OA\Property(property: 'about_me', type: 'string', nullable: true),
                        new OA\Property(property: 'has_photo', type: 'boolean'),
                        new OA\Property(property: 'first_access', type: 'boolean'),
                        new OA\Property(property: 'photo_url', type: 'string', nullable: true),
                    ]
                )
            )
        ]
    )]
    public function getMe(#[CurrentUser] UserEntity $user): JsonResponse
    {
        // Sécurité : s'assurer que hasPhoto est initialisé
        $hasPhoto = false;
        try {
            $hasPhoto = $user->hasPhoto();
        } catch (\Error $e) {
            $hasPhoto = false;
        }

        $firstAccess = false;
        try {
            $firstAccess = $user->isFirstAccess();
        } catch (\Error $e) {
            $firstAccess = false;
        }

        // Si c'est la première fois qu'on accède à /account/me, mettre first_access à false
        if ($firstAccess) {
            $user->setFirstAccess(false);
            $this->userRepository->save($user);
        }

        // Construire l'URL de la photo si elle existe
        $photoUrl = null;
        if ($hasPhoto) {
            // On suppose que la photo est en jpg, mais on pourrait détecter l'extension réelle
            $photoUrl = '/api/photo/' . $user->getAuthUid() . '.jpg';
        }

        return $this->json([
            'id' => $user->getEmail() ?? $user->getAuthUid(),
            'displayName' => $user->getDisplayName() ?? $user->getUsername(),
            'gender' => $user->getGender(),
            'birthdate' => $user->getBirthdate()?->format('Y-m-d'),
            'about_me' => $user->getAboutMe(),
            'has_photo' => $hasPhoto,
            'first_access' => $firstAccess,
            'photo_url' => $photoUrl,
        ]);
    }

    #[Route('/me', name: 'account_update_me', methods: ['PUT'])]
    #[OA\Put(
        summary: 'Met à jour les informations du compte',
        requestBody: new OA\RequestBody(
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: 'displayName', type: 'string', nullable: true),
                    new OA\Property(property: 'gender', type: 'integer', nullable: true),
                    new OA\Property(property: 'birthdate', type: 'string', format: 'date', nullable: true),
                ]
            )
        )
    )]
    public function updateMe(Request $request, #[CurrentUser] UserEntity $user): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        if (isset($data['displayName'])) {
            $user->setDisplayName($data['displayName']);
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
        $photoUrl = null;

        if ($user->hasPhoto()) {
            // Construire l'URL de la photo
            $photoUrl = '/uploads/photos/' . $user->getAuthUid() . '.jpg';
        }

        return $this->json([
            'photo_url' => $photoUrl,
            'has_photo' => $user->hasPhoto(),
        ]);
    }

    #[Route('/photo', name: 'account_delete_photo', methods: ['DELETE'])]
    public function deletePhoto(#[CurrentUser] UserEntity $user): JsonResponse
    {
        if (!$user->hasPhoto()) {
            return $this->json(['error' => 'Aucune photo à supprimer'], Response::HTTP_BAD_REQUEST);
        }

        try {
            $this->deleteOldPhoto($user);
            $user->updatePhotoStatus(false);
            $this->userRepository->save($user);

            return $this->json([
                'success' => true,
                'message' => 'Photo supprimée avec succès'
            ]);

        } catch (\Exception $e) {
            return $this->json([
                'error' => 'Erreur lors de la suppression: ' . $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Valide le fichier photo
     */
    private function validatePhoto(UploadedFile $file): bool
    {
        // Vérifier la taille
        if ($file->getSize() > self::MAX_FILE_SIZE) {
            return false;
        }

        // Vérifier le type MIME
        $mimeType = $file->getMimeType();
        if (!in_array($mimeType, self::ALLOWED_MIME_TYPES)) {
            return false;
        }

        return true;
    }

    /**
     * Supprime l'ancienne photo
     */
    private function deleteOldPhoto(UserEntity $user): void
    {
        $uploadDir = $this->projectDir . self::PHOTO_UPLOAD_DIR;

        // Chercher tous les fichiers commençant par l'auth_uid
        $pattern = $uploadDir . '/' . $user->getAuthUid() . '.*';
        $oldFiles = glob($pattern);

        foreach ($oldFiles as $file) {
            if (is_file($file)) {
                unlink($file);
            }
        }
    }

    #[Route('/photo', name: 'account_update_photo', methods: ['PUT'])]
    public function updatePhoto(Request $request, #[CurrentUser] UserEntity $user): JsonResponse
    {
        /** @var UploadedFile|null $photo */
        $photo = $request->files->get('photo');

        if (!$photo) {
            return $this->json(['error' => 'Aucune photo fournie'], Response::HTTP_BAD_REQUEST);
        }

        // Validation du fichier
        if (!$this->validatePhoto($photo)) {
            return $this->json([
                'error' => 'Format de fichier invalide. Types acceptés: JPEG, PNG, GIF, WEBP. Taille max: 5MB'
            ], Response::HTTP_BAD_REQUEST);
        }

        try {
            // Créer le dossier d'upload s'il n'existe pas
            $uploadDir = $this->projectDir . self::PHOTO_UPLOAD_DIR;
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }

            // Générer un nom de fichier basé sur l'auth_uid
            $extension = $photo->guessExtension() ?? 'jpg';
            $filename = $user->getAuthUid() . '.' . $extension;
            $filepath = $uploadDir . '/' . $filename;

            // Supprimer l'ancienne photo si elle existe
            if ($user->hasPhoto()) {
                $this->deleteOldPhoto($user);
            }

            // Déplacer le fichier
            $photo->move($uploadDir, $filename);

            // Mettre à jour le statut has_photo
            $user->updatePhotoStatus(true);
            $this->userRepository->save($user);

            // Construire l'URL de la photo via notre nouveau controller
            $photoUrl = '/api/photo/' . $filename;

            return $this->json([
                'success' => true,
                'photo_url' => $photoUrl,
                'has_photo' => true,
                'message' => 'Photo téléchargée avec succès'
            ]);

        } catch (\Exception $e) {
            return $this->json([
                'error' => 'Erreur lors du téléchargement: ' . $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
}
