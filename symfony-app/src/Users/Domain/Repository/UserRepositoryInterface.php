<?php

declare(strict_types=1);

namespace App\Users\Domain\Repository;

use App\Users\Domain\Entity\User;

interface UserRepositoryInterface
{
    public function add(User $user): void;
    public function update(User $user): void;
    public function findByAuthUid(string $authUid): ?User;
    public function findByUid(string $uid): ?User;
    public function findDetailedByUid(string $uid, float $myLatitude, float $myLongitude): array;
    public function findByEmail(string $email): ?User;
    public function getUserByAuthUid(string $firebaseAuthId): ?User;
    public function getFilteredList(bool $totally, int $myIdUser, int $skip, int $genderWanted, int $minAge, int $maxAge, int $maxDistance, bool $onlyWithPhoto, bool $onlyInFavorites, float $myLatitude, float $myLongitude): array;
    public function getRandomList(int $myIdUser, array $excludedUsers, int $genderWanted, int $minAge, int $maxAge, int $maxDistance, bool $onlyWithPhoto, bool $onlyInFavorites, float $myLatitude, float $myLongitude, int $nbMax = -1, bool $excludeFake = false): array;
    public function getAllPhotosByUsers(array $listIdUsers): array;
    public function findManyByUids(array $contactsUids);
    public function getContactsFilteredList(int $idUser): array;
    public function findByUsername(string $username): ?User;

    public function getListFromIds(int $myIdUser, array $usersIds, float $myLatitude, float $myLongitude): array;

}
