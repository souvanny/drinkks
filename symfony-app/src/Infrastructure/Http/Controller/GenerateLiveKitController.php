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
    )
    {
    }

    #[Route('', name: 'sfu_generate_token', methods: ['POST'])]
    #[OA\Post(
        description: 'sfu_generate_token',
        summary: 'sfu_generate_token',
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['participant_identity', 'participant_name', 'participant_metadata', 'participant_attributes', 'room_name', 'room_config'],
            )
        ),
    )]
    public function generateSfuToken(): JsonResponse
    {
        // Left as an exercise to the reader: Make sure this is running on port 3000.

        // Get the incoming JSON request body
        $rawBody = file_get_contents('php://input');
        $body = json_decode($rawBody, true);

        // Validate that we have valid JSON
        if (json_last_error() !== JSON_ERROR_NONE) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid JSON in request body']);
            exit;
        }

        // Define the token options.
        $tokenOptions = (new AccessTokenOptions())
            // Participant related fields.
            // `participantIdentity` will be available as LocalParticipant.identity
            // within the livekit-client SDK
            ->setIdentity($body['participant_identity'] ?? 'quickstart-identity')
            ->setName($body['participant_name'] ?? 'quickstart-username');

        if (!empty($body["participant_metadata"])) {
            $tokenOptions = $tokenOptions->setMetadata($body["participant_metadata"]);
        }
        if (!empty($body["participant_attributes"])) {
            $tokenOptions = $tokenOptions->setAttributes($body["participant_attributes"]);
        }

        // Define the video grants.
        $roomName = $body['room_name'] ?? 'quickstart-room';
        $videoGrant = (new VideoGrant())
            ->setRoomJoin()
            // If this room doesn't exist, it'll be automatically created when
            // the first participant joins
            ->setRoomName($roomName);


        $token = (new AccessToken(getenv('LIVEKIT_API_KEY'), getenv('LIVEKIT_API_SECRET')))
            ->init($tokenOptions)
            ->setGrant($videoGrant);

        if (!empty($body["room_config"])) {
            $token = $token->setRoomConfig($body["room_config"]);
        }

        echo json_encode([ 'server_url' => getenv('LIVEKIT_URL'), 'participant_token' => $token->toJwt() ]);

        return $this->json([]);
    }

}
