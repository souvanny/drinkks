<?php

namespace App\Infrastructure\Http\Controller;

use Exception;
use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Agence104\LiveKit\RoomServiceClient;
use Agence104\LiveKit\RoomCreateOptions;

#[Route('/api/sfu')]
#[OA\Tag(name: 'sfu')]
class LiveKitListRoomsController extends AbstractController
{
    public function __construct(
        private readonly string $livekitApiKey,
        private readonly string $livekitApiSecret,
        private readonly string $livekitUrl,
    ) {
    }

    #[Route('/rooms/list', name: 'sfu_list_rooms', methods: ['GET'])]
    public function listRooms(): JsonResponse
    {

        /**
         * https://github.com/agence104/livekit-server-sdk-php
         */

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

        $listRooms = $svc->listRooms();

        $allParticipants = [];

        foreach ($listRooms->getRooms() as $room) {
//            echo "Salon : **" . $room->getName() . "**\n";
//            echo "Nombre de participants : " . $room->getNumParticipants() . "\n";

            // 2. Récupérer les utilisateurs connectés pour ce salon spécifique
            $listParticipants = $svc->listParticipants($room->getName());
            $allParticipants[$room->getSid()] = $listParticipants->getParticipants();

//            if (count($participants) > 0) {
//                echo "Utilisateurs présents :\n";
//                foreach ($participants as $p) {
//                    // Affiche l'identité et le statut (actif/en attente)
//                    echo "- " . $p->getIdentity() . " (Statut: " . $p->getState() . ")\n";
//                }
//            } else {
//                echo "- Aucun utilisateur connecté.\n";
//            }
//            echo "---\n";
        }

        return $this->json([
            'rooms' => $rooms,
            'participants' => $allParticipants,
        ], Response::HTTP_OK);
    }
}
