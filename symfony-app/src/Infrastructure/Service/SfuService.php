<?php

namespace App\Infrastructure\Service;

class SfuService
{

    private $livekitApiKey;
    private $livekitApiSecret;
    private $livekitUrlHttp;
    private $livekitUrlWss;
    public function __construct(
        string $livekitApiKey,
        string $livekitApiSecret,
        string $livekitUrlWss,
        string $livekitUrlHttp,
    ) {
        $this->livekitApiKey = $livekitApiKey;
        $this->livekitApiSecret = $livekitApiSecret;
        $this->livekitUrlWss = $livekitUrlWss;
        $this->livekitUrlHttp = $livekitUrlHttp;
    }

    public function getLivekitApiKey(): string
    {
        return $this->livekitApiKey;
    }

    public function setLivekitApiKey(string $livekitApiKey): void
    {
        $this->livekitApiKey = $livekitApiKey;
    }

    public function getLivekitApiSecret(): string
    {
        return $this->livekitApiSecret;
    }

    public function setLivekitApiSecret(string $livekitApiSecret): void
    {
        $this->livekitApiSecret = $livekitApiSecret;
    }

    public function getLivekitUrlHttp(): string
    {
        return $this->livekitUrlHttp;
    }

    public function setLivekitUrlHttp(string $livekitUrlHttp): void
    {
        $this->livekitUrlHttp = $livekitUrlHttp;
    }

    public function getLivekitUrlWss(): string
    {
        return $this->livekitUrlWss;
    }

    public function setLivekitUrlWss(string $livekitUrlWss): void
    {
        $this->livekitUrlWss = $livekitUrlWss;
    }

}
