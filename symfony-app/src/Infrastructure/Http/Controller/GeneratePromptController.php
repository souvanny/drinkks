<?php

namespace App\Infrastructure\Http\Controller;

use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Finder\Finder;

#[Route('/api/generate-prompt')]
#[OA\Tag(name: 'IA Assistant', description: 'Génération de prompts pour l\'IA')]
class GeneratePromptController extends AbstractController
{
    #[Route('', name: 'generate_prompt', methods: ['GET'])]
    #[OA\Get(
//        path: '/generate-prompt',
        description: 'Exporte tous les fichiers d\'un dossier avec leurs extensions spécifiées au format texte brut pour analyse par IA',
        summary: 'Génère un prompt texte contenant l\'arborescence et le code source',
        parameters: [
            new OA\Parameter(
                name: 'path',
                description: 'Chemin du dossier à analyser (absolu ou relatif à la racine du projet)',
                in: 'query',
                required: true,
                schema: new OA\Schema(
                    type: 'string',
                    default: 'src',
                    example: 'src/Controller'
                )
            ),
            new OA\Parameter(
                name: 'extensions',
                description: 'Liste des extensions de fichiers à inclure (séparées par des virgules)',
                in: 'query',
                required: true,
                schema: new OA\Schema(
                    type: 'string',
                    default: 'php,dart,html,twig,js,css',
                    example: 'php,twig,yaml'
                )
            ),
        ]

    )]
    public function generatePrompt(Request $request): Response
    {
        $path = $request->query->get('path', 'src');
        $extensions = $request->query->get('extensions', 'php,dart,html,twig,js,css');


        // Résoudre le chemin absolu
        if (!str_starts_with($path, '/')) {
            $path = $this->getParameter('kernel.project_dir') . '/' . $path;
        }

        $path = realpath($path);

        if (!$path || !is_dir($path)) {
            return new Response(
                "ERREUR: Le dossier '$path' n'existe pas ou n'est pas accessible\n",
                Response::HTTP_NOT_FOUND,
                ['Content-Type' => 'text/plain']
            );
        }

        $allowedExtensions = array_map('trim', explode(',', $extensions));

        try {
            $content = $this->generateExport($path, $allowedExtensions);

            return new Response(
                $content,
                Response::HTTP_OK,
                ['Content-Type' => 'text/plain']
            );

        } catch (\Exception $e) {
            return new Response(
                "ERREUR: " . $e->getMessage() . "\n",
                Response::HTTP_INTERNAL_SERVER_ERROR,
                ['Content-Type' => 'text/plain']
            );
        }
    }

    private function generateExport(string $rootPath, array $allowedExtensions): string
    {
        $output = [];

        // En-tête
        $output[] = "PROMPT POUR ANALYSE IA";
        $output[] = "=====================";
        $output[] = "Dossier: " . $rootPath;
        $output[] = "Extensions: " . implode(', ', $allowedExtensions);
        $output[] = "Date: " . date('Y-m-d H:i:s');
        $output[] = "";

        // Trouver tous les fichiers
        $finder = new Finder();
        $finder->files()
            ->in($rootPath)
            ->ignoreDotFiles(false)
            ->ignoreVCS(false);

        // Compter d'abord pour l'arborescence
        $allFiles = [];
        foreach ($finder as $file) {
            $ext = $file->getExtension();
            if (in_array($ext, $allowedExtensions)) {
                $allFiles[] = $file;
            }
        }

        // Trier par chemin
        usort($allFiles, function($a, $b) {
            return strcmp($a->getRelativePathname(), $b->getRelativePathname());
        });

        // Générer l'arborescence textuelle simple
        $output[] = "ARBORESCENCE:";
        $output[] = "-------------";

        if (empty($allFiles)) {
            $output[] = "  (aucun fichier trouvé avec ces extensions)";
        } else {
            $lastPath = '';
            foreach ($allFiles as $file) {
                $relativePath = $file->getRelativePathname();
                $depth = substr_count($relativePath, DIRECTORY_SEPARATOR);
                $indent = str_repeat('  ', $depth);
                $output[] = $indent . '📄 ' . basename($relativePath);
            }
        }

        $output[] = "";
        $output[] = "CONTENU DES FICHIERS";
        $output[] = "====================";
        $output[] = "";

        // Contenu de chaque fichier
        if (empty($allFiles)) {
            $output[] = "Aucun fichier à afficher.";
        } else {
            foreach ($allFiles as $file) {
                $relativePath = $file->getRelativePathname();

                $output[] = "FICHIER: " . $relativePath;
                $output[] = str_repeat("-", 80);

                $content = file_get_contents($file->getRealPath());
                if ($content === false) {
                    $output[] = "[ERREUR LECTURE]";
                } else {
                    // On garde le contenu original sans modification
                    $output[] = $content;
                }

                $output[] = ""; // Ligne vide entre les fichiers
                $output[] = ""; // Une de plus pour la séparation
            }
        }

        $output[] = "FIN DU PROMPT";
        $output[] = "============";
        $output[] = "Total fichiers: " . count($allFiles);

        return implode("\n", $output);
    }
}
