<?php

namespace App\Infrastructure\Http\Controller;

use OpenApi\Attributes as OA;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Finder\Finder;

#[Route('/api/generate-prompt')]
#[OA\Tag(name: 'ia assistant', description: 'Génération de prompts pour l\'IA')]
class GeneratePromptController extends AbstractController
{
    #[Route('', name: 'generate_prompt', methods: ['GET'])]
    #[OA\Get(
        description: 'Exporte des fichiers et dossiers au format texte brut pour analyse par IA',
        summary: 'Génère un prompt texte contenant l\'arborescence et le code source',
        parameters: [
            new OA\Parameter(
                name: 'paths',
                description: 'Chemin des dossiers à analyser (séparés par des virgules) - absolus ou relatifs à la racine du projet',
                in: 'query',
                required: false,
                schema: new OA\Schema(
                    type: 'string',
                    example: 'src,config,templates'
                )
            ),
            new OA\Parameter(
                name: 'files',
                description: 'Chemin des fichiers individuels à analyser (séparés par des virgules) - absolus ou relatifs à la racine du projet',
                in: 'query',
                required: false,
                schema: new OA\Schema(
                    type: 'string',
                    example: 'src/Controller/GeneratePromptController.php,config/routes.yaml'
                )
            ),
            new OA\Parameter(
                name: 'extensions',
                description: 'Liste des extensions de fichiers à inclure (séparées par des virgules)',
                in: 'query',
                required: false,
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
        $pathsParam = $request->query->get('paths');
        $filesParam = $request->query->get('files');
        $extensions = $request->query->get('extensions', 'php,dart,html,twig,js,css');

        // Vérifier qu'au moins un paramètre est fourni
        if (!$pathsParam && !$filesParam) {
            return new Response(
                "ERREUR: Vous devez fournir au moins un dossier (paths) ou un fichier (files) à analyser.\n",
                Response::HTTP_BAD_REQUEST,
                ['Content-Type' => 'text/plain']
            );
        }

        $allowedExtensions = array_map('trim', explode(',', $extensions));
        $warningMessages = [];
        $allFiles = [];
        $allDirs = [];

        // Traitement des dossiers (paths)
        $resolvedPaths = [];
        if ($pathsParam) {
            $rawPaths = array_map('trim', explode(',', $pathsParam));

            foreach ($rawPaths as $path) {
                // Résoudre le chemin absolu
                if (!str_starts_with($path, '/')) {
                    $path = $this->getParameter('kernel.project_dir') . '/' . $path;
                }

                $realPath = realpath($path);

                if ($realPath && is_dir($realPath)) {
                    $resolvedPaths[] = $realPath;
                } else {
                    $warningMessages[] = "Dossier ignoré (invalide): " . $path;
                }
            }

            // Collecter les fichiers des dossiers valides
            foreach ($resolvedPaths as $rootPath) {
                $finder = new Finder();
                $finder->files()
                    ->in($rootPath)
                    ->ignoreDotFiles(false)
                    ->ignoreVCS(false);

                foreach ($finder as $file) {
                    $ext = $file->getExtension();
                    if (in_array($ext, $allowedExtensions)) {
                        $allFiles[] = $file;

                        // Collecter tous les dossiers parents
                        $relativePath = $file->getRelativePath();
                        if (!empty($relativePath)) {
                            $parts = explode(DIRECTORY_SEPARATOR, $relativePath);
                            $currentPath = '';
                            foreach ($parts as $part) {
                                $currentPath = empty($currentPath) ? $part : $currentPath . DIRECTORY_SEPARATOR . $part;
                                $allDirs[$currentPath] = true;
                            }
                        }
                    }
                }
            }
        }

        // Traitement des fichiers individuels (files)
        $resolvedFiles = [];
        if ($filesParam) {
            $rawFiles = array_map('trim', explode(',', $filesParam));

            foreach ($rawFiles as $file) {
                // Résoudre le chemin absolu
                if (!str_starts_with($file, '/')) {
                    $file = $this->getParameter('kernel.project_dir') . '/' . $file;
                }

                $realPath = realpath($file);

                if ($realPath && is_file($realPath)) {
                    $ext = pathinfo($realPath, PATHINFO_EXTENSION);
                    if (in_array($ext, $allowedExtensions)) {
                        $resolvedFiles[] = $realPath;

                        // Créer un objet fichier virtuel pour le traitement
                        $virtualFile = new \SplFileInfo($realPath);
                        $allFiles[] = $virtualFile;

                        // Collecter le dossier parent
                        $relativePath = str_replace($this->getParameter('kernel.project_dir') . '/', '', dirname($realPath));
                        if ($relativePath !== '.' && !empty($relativePath)) {
                            $parts = explode(DIRECTORY_SEPARATOR, $relativePath);
                            $currentPath = '';
                            foreach ($parts as $part) {
                                $currentPath = empty($currentPath) ? $part : $currentPath . DIRECTORY_SEPARATOR . $part;
                                $allDirs[$currentPath] = true;
                            }
                        }
                    } else {
                        $warningMessages[] = "Fichier ignoré (extension non autorisée): " . $file;
                    }
                } else {
                    $warningMessages[] = "Fichier ignoré (invalide): " . $file;
                }
            }
        }

        // Vérifier qu'on a au moins un fichier à analyser
        if (empty($allFiles)) {
            $errorMsg = "ERREUR: Aucun fichier valide trouvé.\n";
            if (!empty($warningMessages)) {
                $errorMsg .= implode("\n", $warningMessages) . "\n";
            }
            return new Response(
                $errorMsg,
                Response::HTTP_NOT_FOUND,
                ['Content-Type' => 'text/plain']
            );
        }

        try {
            $content = $this->generateExport($allFiles, $allDirs, $resolvedPaths, $allowedExtensions);

            // Ajouter les avertissements au début si nécessaire
            if (!empty($warningMessages)) {
                $warnings = "ATTENTIONS:\n" . implode("\n", $warningMessages) . "\n\n";
                $content = $warnings . $content;
            }

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

    private function generateExport(array $allFiles, array $allDirs, array $rootPaths, array $allowedExtensions): string
    {
        $output = [];
        $projectRoot = $this->getParameter('kernel.project_dir');

        // En-tête
        $output[] = "FICHIERS POUR ANALYSE";
        $output[] = "=====================";

        if (!empty($rootPaths)) {
            $output[] = "Dossiers analysés:";
            foreach ($rootPaths as $path) {
                $relativePath = str_replace($projectRoot . '/', '', $path);
                $output[] = "  - " . $relativePath;
            }
        }

        $output[] = "Extensions: " . implode(', ', $allowedExtensions);
        $output[] = "Date: " . date('Y-m-d H:i:s');
        $output[] = "";

        // Trier les fichiers par chemin
        usort($allFiles, function($a, $b) {
            return strcmp($a->getRealPath(), $b->getRealPath());
        });

        // Trier les dossiers
        $dirs = array_keys($allDirs);
        sort($dirs);

        // Générer l'arborescence complète
        $output[] = "ARBORESCENCE:";
        $output[] = "-------------";

        if (empty($allFiles)) {
            $output[] = "  (aucun fichier trouvé)";
        } else {
            // Construire l'arbre global
            $globalTree = [];

            foreach ($allFiles as $file) {
                $fullPath = $file->getRealPath();
                $relativePath = str_replace($projectRoot . '/', '', $fullPath);
                $parts = explode('/', $relativePath);

                $current = &$globalTree;
                $lastIndex = count($parts) - 1;

                foreach ($parts as $index => $part) {
                    if ($index === $lastIndex) {
                        // C'est un fichier
                        $current[$part] = null;
                    } else {
                        // C'est un dossier
                        if (!isset($current[$part])) {
                            $current[$part] = [];
                        }
                        $current = &$current[$part];
                    }
                }
            }

            $output[] = $this->renderTree($globalTree);
        }

        $output[] = "";
        $output[] = "CONTENU DES FICHIERS";
        $output[] = "====================";
        $output[] = "";

        // Contenu de chaque fichier
        foreach ($allFiles as $file) {
            $fullPath = $file->getRealPath();
            $relativeToProject = str_replace($projectRoot . '/', '', $fullPath);

            $output[] = "FICHIER: " . $relativeToProject;
            $output[] = str_repeat("-", 80);

            $content = file_get_contents($fullPath);
            if ($content === false) {
                $output[] = "[ERREUR LECTURE]";
            } else {
                $output[] = $content;
            }

            $output[] = ""; // Ligne vide entre les fichiers
            $output[] = ""; // Une de plus pour la séparation
        }

        $output[] = "FIN";
        $output[] = "============";
        $output[] = "Total fichiers: " . count($allFiles);

        return implode("\n", $output);
    }

    private function renderTree(array $tree, string $prefix = ''): string
    {
        $output = '';
        $items = $this->sortTreeItems($tree);
        $count = count($items);
        $i = 0;

        foreach ($items as $key => $value) {
            $i++;
            $isLast = ($i === $count);
            $isDir = is_array($value);

            // Choisir le marqueur
            if ($isDir) {
                $marker = $isLast ? '└── 📁 ' : '├── 📁 ';
            } else {
                $marker = $isLast ? '└── 📄 ' : '├── 📄 ';
            }

            // Ajouter l'élément courant
            $output .= $prefix . $marker . $key . ($isDir ? '/' : '') . "\n";

            // Si c'est un dossier, rendre son contenu
            if ($isDir) {
                $newPrefix = $prefix . ($isLast ? '    ' : '│   ');
                $output .= $this->renderTree($value, $newPrefix);
            }
        }

        return $output;
    }

    private function sortTreeItems(array $tree): array
    {
        // Séparer les dossiers et les fichiers
        $dirs = [];
        $files = [];

        foreach ($tree as $key => $value) {
            if (is_array($value)) {
                $dirs[$key] = $value;
            } else {
                $files[$key] = $value;
            }
        }

        // Trier alphabétiquement
        ksort($dirs);
        ksort($files);

        // Fusionner (dossiers d'abord, puis fichiers)
        return array_merge($dirs, $files);
    }
}
