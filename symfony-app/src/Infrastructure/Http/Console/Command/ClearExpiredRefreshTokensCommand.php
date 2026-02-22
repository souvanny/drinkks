<?php
// src/Infrastructure/Console/Command/ClearExpiredRefreshTokensCommand.php

namespace App\Infrastructure\Console\Command;

use App\Infrastructure\Persistence\Doctrine\Repository\RefreshTokenRepository;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'app:clear-expired-refresh-tokens',
    description: 'Supprime les refresh tokens expirés'
)]
class ClearExpiredRefreshTokensCommand extends Command
{
    public function __construct(
        private readonly RefreshTokenRepository $refreshTokenRepository
    ) {
        parent::__construct();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $deleted = $this->refreshTokenRepository->deleteExpired();
        $output->writeln(sprintf('%d refresh tokens expirés supprimés.', $deleted));

        return Command::SUCCESS;
    }
}
