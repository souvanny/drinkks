<?php

namespace App\Infrastructure\Http\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\ResponseHeaderBag;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/photo')]
class PhotoController extends AbstractController
{
    private string $uploadDir;

    public function __construct(string $projectDir)
    {
        $this->uploadDir = $projectDir . '/upload/photos';
    }

    #[Route('/{filename}', name: 'photo_get', methods: ['GET'])]
    public function getPhoto(string $filename): Response
    {
        // Sécurité : empêcher les traversées de répertoire
        if (str_contains($filename, '..') || str_contains($filename, '/') || str_contains($filename, '\\')) {
            return new JsonResponse(['error' => 'Nom de fichier invalide'], Response::HTTP_BAD_REQUEST);
        }

        // Validation du format de fichier - CORRIGÉE
        // Accepte: lettres (maj/min), chiffres, tirets, underscore, points
        if (!preg_match('/^[a-zA-Z0-9_-]+\.(jpg|jpeg|png|gif|webp)$/i', $filename)) {
            return new JsonResponse([
                'error' => 'Format de fichier invalide',
                'filename' => $filename,
                'expected_format' => 'auth_uid.extension (ex: AtJbLX0UgIcpiaWCZNnc9JdLzff1.jpg)'
            ], Response::HTTP_BAD_REQUEST);
        }

        $filePath = $this->uploadDir . '/' . $filename;

        if (!file_exists($filePath)) {
            return new JsonResponse(['error' => 'Photo non trouvée'], Response::HTTP_NOT_FOUND);
        }

        // Détecter le type MIME
        $mimeType = mime_content_type($filePath);
        if (!$mimeType) {
            $extension = pathinfo($filename, PATHINFO_EXTENSION);
            $mimeType = match(strtolower($extension)) {
                'jpg', 'jpeg' => 'image/jpeg',
                'png' => 'image/png',
                'gif' => 'image/gif',
                'webp' => 'image/webp',
                default => 'application/octet-stream',
            };
        }

        // Retourner le fichier avec des en-têtes de cache
        return new BinaryFileResponse($filePath, 200, [
            'Content-Type' => $mimeType,
            'Cache-Control' => 'public, max-age=31536000', // Cache d'un an
            'Access-Control-Allow-Origin' => '*', // Permettre l'accès depuis n'importe quelle origine
        ]);
    }

    #[Route('/{filename}/download', name: 'photo_download', methods: ['GET'])]
    public function downloadPhoto(string $filename): Response
    {
        // Même logique de sécurité
        if (str_contains($filename, '..') || str_contains($filename, '/') || str_contains($filename, '\\')) {
            return new JsonResponse(['error' => 'Nom de fichier invalide'], Response::HTTP_BAD_REQUEST);
        }

        if (!preg_match('/^[a-f0-9-]+\.(jpg|jpeg|png|gif|webp)$/i', $filename)) {
            return new JsonResponse(['error' => 'Format de fichier invalide'], Response::HTTP_BAD_REQUEST);
        }

        $filePath = $this->uploadDir . '/' . $filename;

        if (!file_exists($filePath)) {
            return new JsonResponse(['error' => 'Photo non trouvée'], Response::HTTP_NOT_FOUND);
        }

        $response = new BinaryFileResponse($filePath);
        $response->setContentDisposition(
            ResponseHeaderBag::DISPOSITION_ATTACHMENT,
            $filename
        );
        $response->headers->set('Access-Control-Allow-Origin', '*');

        return $response;
    }
}
