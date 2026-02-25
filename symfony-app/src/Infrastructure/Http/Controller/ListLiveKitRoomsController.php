<?php

namespace App\Infrastructure\Http\Controller;

use Exception;
//use Livekit\RoomServiceClient;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Agence104\LiveKit\RoomServiceClient;
use Agence104\LiveKit\RoomCreateOptions;

#[Route('/api/sfu/rooms')]
#[OA\Tag(name: 'sfu')]
class ListLiveKitRoomsController extends AbstractController
{
    public function __construct(
        private readonly string $livekitApiKey,
        private readonly string $livekitApiSecret,
        private readonly string $livekitUrl,
    ) {
    }

    #[Route('', name: 'sfu_list_rooms', methods: ['GET'])]
    public function listRooms(): JsonResponse
    {


        $host = 'https://livekit.project-takagi.fr';
        $svc = new RoomServiceClient($host, 'APITCL53pSLyZaR', 'G2qNPc1PjNjfhdGGzwORQ7v4aLDhsNovnFN36PMXeho');

        // List rooms.
        $rooms = $svc->listRooms();

        // Create a new room.
        $opts = (new RoomCreateOptions())
            ->setName('myroom')
            ->setEmptyTimeout(10)
            ->setMaxParticipants(4);
        $room = $svc->createRoom($opts);

        // Delete a room.
        $svc->deleteRoom('myroom');

        $rooms = $svc->listRooms();


        return $this->json([
            'rooms' => $rooms,
        ], Response::HTTP_OK);
    }
}
