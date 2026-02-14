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
        description: 'Exporte tous les fichiers d\'un ou plusieurs dossiers avec leurs extensions spécifiées au format texte brut pour analyse par IA',
        summary: 'Génère un prompt texte contenant l\'arborescence et le code source',
        parameters: [
            new OA\Parameter(
                name: 'paths',
                description: 'Chemin des dossiers à analyser (séparés par des virgules) - absolus ou relatifs à la racine du projet',
                in: 'query',
                required: false,
                schema: new OA\Schema(
                    type: 'string',
                    default: 'src',
                    example: 'src,config,templates'
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
        $pathsParam = $request->query->get('paths', 'src');
        $extensions = $request->query->get('extensions', 'php,dart,html,twig,js,css');

        // Séparer les différents chemins
        $rawPaths = array_map('trim', explode(',', $pathsParam));
        $resolvedPaths = [];
        $invalidPaths = [];

        foreach ($rawPaths as $path) {
            // Résoudre le chemin absolu
            if (!str_starts_with($path, '/')) {
                $path = $this->getParameter('kernel.project_dir') . '/' . $path;
            }

            $realPath = realpath($path);

            if ($realPath && is_dir($realPath)) {
                $resolvedPaths[] = $realPath;
            } else {
                $invalidPaths[] = $path;
            }
        }

        // Si aucun dossier valide
        if (empty($resolvedPaths)) {
            $errorMsg = "ERREUR: Aucun dossier valide trouvé.\n";
            if (!empty($invalidPaths)) {
                $errorMsg .= "Dossiers invalides: " . implode(', ', $invalidPaths) . "\n";
            }
            return new Response(
                $errorMsg,
                Response::HTTP_NOT_FOUND,
                ['Content-Type' => 'text/plain']
            );
        }

        // Avertir si certains dossiers sont invalides
        if (!empty($invalidPaths)) {
            $errorMsg = "ATTENTION: Certains dossiers n'existent pas: " . implode(', ', $invalidPaths) . "\n\n";
        } else {
            $errorMsg = "";
        }

        $allowedExtensions = array_map('trim', explode(',', $extensions));

        try {
            $content = $this->generateExport($resolvedPaths, $allowedExtensions);

            return new Response(
                $errorMsg . $content,
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

    private function generateExport(array $rootPaths, array $allowedExtensions): string
    {
        $output = [];

        // En-tête
        $output[] = "FICHIERS POUR ANALYSE";
        $output[] = "=====================";
        $output[] = "Dossiers analysés:";
        foreach ($rootPaths as $path) {
            $output[] = "  - " . $path;
        }
        $output[] = "Extensions: " . implode(', ', $allowedExtensions);
        $output[] = "Date: " . date('Y-m-d H:i:s');
        $output[] = "";

        // Collecter tous les fichiers de tous les dossiers
        $allFiles = [];
        $allDirs = [];
        $totalFiles = 0;

        foreach ($rootPaths as $rootPath) {
            $finder = new Finder();
            $finder->files()
                ->in($rootPath)
                ->ignoreDotFiles(false)
                ->ignoreVCS(false);

            foreach ($finder as $file) {
                $ext = $file->getExtension();
                if (in_array($ext, $allowedExtensions)) {
                    // Stocker avec le chemin complet pour éviter les collisions
                    $allFiles[] = $file;
                    $totalFiles++;

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

        // Trier les fichiers par chemin complet
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
            $output[] = "  (aucun fichier trouvé avec ces extensions)";
        } else {
            // Pour chaque dossier racine, construire son arbre
            foreach ($rootPaths as $rootPath) {
                $rootName = basename($rootPath) . " (" . $rootPath . ")";
                $output[] = "📁 " . $rootName . "/";

                // Filtrer les fichiers et dossiers pour cette racine
                $rootFiles = array_filter($allFiles, function($file) use ($rootPath) {
                    return strpos($file->getRealPath(), $rootPath) === 0;
                });

                $rootDirs = array_filter($dirs, function($dir) use ($rootPath, $rootFiles) {
                    // Ne garder que les dossiers qui contiennent des fichiers
                    foreach ($rootFiles as $file) {
                        if (strpos($file->getRelativePath(), $dir) === 0) {
                            return true;
                        }
                    }
                    return false;
                });

                $tree = $this->buildTree($rootPath, $rootDirs, $rootFiles);
                $output[] = $this->renderTree($tree, '    ');
                $output[] = ""; // Ligne vide entre les dossiers racines
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
                // Afficher le chemin complet relatif à la racine du projet
                $projectRoot = $this->getParameter('kernel.project_dir');
                $fullPath = $file->getRealPath();
                $relativeToProject = str_replace($projectRoot . '/', '', $fullPath);

                $output[] = "FICHIER: " . $relativeToProject;
                $output[] = str_repeat("-", 80);

                $content = file_get_contents($file->getRealPath());
                if ($content === false) {
                    $output[] = "[ERREUR LECTURE]";
                } else {
                    $output[] = $content;
                }

                $output[] = ""; // Ligne vide entre les fichiers
                $output[] = ""; // Une de plus pour la séparation
            }
        }

        $output[] = "FIN";
        $output[] = "============";
        $output[] = "Total fichiers: " . $totalFiles;

        return implode("\n", $output);
    }

    private function buildTree(string $rootPath, array $dirs, array $files): array
    {
        $tree = [];

        // Ajouter les dossiers
        foreach ($dirs as $dir) {
            $parts = explode(DIRECTORY_SEPARATOR, $dir);
            $current = &$tree;

            foreach ($parts as $part) {
                if (!isset($current[$part])) {
                    $current[$part] = [];
                }
                $current = &$current[$part];
            }
        }

        // Ajouter les fichiers
        foreach ($files as $file) {
            $relativePath = $file->getRelativePath();
            $filename = $file->getFilename();

            if (empty($relativePath)) {
                // Fichier à la racine
                $tree[$filename] = null;
            } else {
                $parts = explode(DIRECTORY_SEPARATOR, $relativePath);
                $current = &$tree;

                foreach ($parts as $part) {
                    if (!isset($current[$part])) {
                        $current[$part] = [];
                    }
                    $current = &$current[$part];
                }

                $current[$filename] = null;
            }
        }

        return $tree;
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
