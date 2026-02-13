<?php

namespace App\Infrastructure\Http\Controller;

use Agence104\LiveKit\AccessToken;
use Agence104\LiveKit\AccessTokenOptions;
use Agence104\LiveKit\VideoGrant;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/sfu/generate-token')]
#[OA\Tag(name: 'sfu')]
class GenerateLiveKitController extends AbstractController
{
    public function __construct(
        private readonly string $livekitApiKey,
        private readonly string $livekitApiSecret,
        private readonly string $livekitUrl,
    ) {
    }

    #[Route('', name: 'sfu_generate_token', methods: ['POST'])]
    #[OA\Post(
        description: 'Génère un token JWT pour LiveKit SFU',
        summary: 'Générer un token d\'accès LiveKit',
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['participant_identity', 'room_name'],
                properties: [
                    new OA\Property(property: 'participant_identity', type: 'string', description: 'Identifiant unique du participant'),
                    new OA\Property(property: 'participant_name', type: 'string', description: 'Nom du participant'),
                    new OA\Property(property: 'participant_metadata', type: 'string', description: 'Métadonnées du participant'),
                    new OA\Property(property: 'participant_attributes', type: 'object', description: 'Attributs du participant'),
                    new OA\Property(property: 'room_name', type: 'string', description: 'Nom de la salle'),
                    new OA\Property(property: 'room_config', type: 'object', description: 'Configuration de la salle'),
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Token généré avec succès',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'server_url', type: 'string', example: 'wss://livekit.example.com'),
                        new OA\Property(property: 'participant_token', type: 'string', example: 'eyJhbGciOiJIUzI1NiIs...'),
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: 'Requête invalide'
            )
        ]
    )]
    public function generateSfuToken(Request $request): JsonResponse
    {
        try {
            // Décoder le corps de la requête JSON
            $body = json_decode($request->getContent(), true);

            // Valider que nous avons du JSON valide
            if (json_last_error() !== JSON_ERROR_NONE) {
                return $this->json([
                    'error' => 'Invalid JSON in request body'
                ], Response::HTTP_BAD_REQUEST);
            }

            // Valider les champs requis
            if (!isset($body['participant_identity']) || !isset($body['room_name'])) {
                return $this->json([
                    'error' => 'Missing required fields: participant_identity and room_name are required'
                ], Response::HTTP_BAD_REQUEST);
            }

            // Définir les options du token
            $tokenOptions = (new AccessTokenOptions())
                ->setIdentity($body['participant_identity'])
                ->setName($body['participant_name'] ?? $body['participant_identity']);

            // Ajouter les métadonnées si présentes
            if (!empty($body['participant_metadata'])) {
                $tokenOptions = $tokenOptions->setMetadata($body['participant_metadata']);
            }

            // Ajouter les attributs si présents
            if (!empty($body['participant_attributes']) && is_array($body['participant_attributes'])) {
                $tokenOptions = $tokenOptions->setAttributes($body['participant_attributes']);
            }

            // Définir les grants vidéo
            $roomName = $body['room_name'];
            $videoGrant = (new VideoGrant())
                ->setRoomJoin()
                ->setRoomName($roomName);

            // Créer le token
            $token = (new AccessToken($this->livekitApiKey, $this->livekitApiSecret))
                ->init($tokenOptions)
                ->setGrant($videoGrant);

            // Ajouter la configuration de la salle si présente
            if (!empty($body['room_config']) && is_array($body['room_config'])) {
                $token = $token->setRoomConfig($body['room_config']);
            }

            // Retourner la réponse JSON
            return $this->json([
                'server_url' => $this->livekitUrl,
                'participant_token' => $token->toJwt()
            ]);

        } catch (\Exception $e) {
            return $this->json([
                'error' => 'Failed to generate token: ' . $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
}
