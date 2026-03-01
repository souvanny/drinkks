<?php

namespace App\Infrastructure\Http\Controller;

use App\Infrastructure\Service\SfuService;
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
class LiveKitWebhook1Controller extends AbstractController
{
    public function __construct(
        private readonly SfuService $sfuService,
    ) {
    }

    #[Route('/webhook1', name: 'sfu_webhook1', methods: ['GET'])]
    public function listRooms(): JsonResponse
    {

        /**
         * https://github.com/agence104/livekit-server-sdk-php
         */

        $host = $this->sfuService->getLivekitUrlHttp();
        $svc = new RoomServiceClient($host, $this->sfuService->getLivekitApiKey(), $this->sfuService->getLivekitApiSecret());

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
