<?php

namespace App\Users\Application\Config;

class UsersAppConfig
{
    static int $ERREUR_FATAL = 1;
    static int $ERREUR_SYSTEM_INFO = 2;
    static int $ERREUR_USER = 3;
    static int $USER_NEED_RESTART = 10; // temporaire
    static int $USER_BANNED = 20; // définitif
    static int $USER_BLOCKED = 30; // temporaire
    static int $USER_UNSUBSCRIBED = 50; // définitif


    static int $RANDOM_LIMIT = 10;
    static int $RANDOM_TIME_LIMIT = 5;
    static int $RANDOM_HISTORY_TIME_LIMIT = 604800;
    static string $SLOT_SECRET = "Nu31Xc8em6X76UKGJxqAOTClh6egRT8vAMQYbQdSqVBuToYcFN";
    static int $LINK_SUGGESTED = 1;
    static int $LINK_ACCEPTED = 2;
    static int $LINK_DECLINED = 3;
    static int $LINK_SLOT_WIN = 4;
    static int $NOTIFICATION_STATE_NEW = 0;
    static int $NOTIFICATION_STATE_READ = 1;
    static int $FOLLOW_TYPE_VISIT = 01;
    static int $FOLLOW_TYPE_MANAGE_CONTACT_SUGGEST = 11;
    static int $FOLLOW_TYPE_MANAGE_CONTACT_ACCEPT = 12;
    static int $FOLLOW_TYPE_MANAGE_CONTACT_DECLINE = 13;
    static int $FOLLOW_TYPE_SLOT_WIN = 21;


    static int $NOTIFICATION_TYPE_CONTACT = 1;
    static int $NOTIFICATION_TYPE_SLOT_WIN = 3;
    static int $NOTIFICATION_TYPE_MESSAGE = 10;

    static int $CREDITS_BY_NB_WON = 5;
    static int $FREE_DAY_CREDITS = 50;


    static int $CREDIT_LOG_REASON_DAY_FREE = 1;
    static int $CREDIT_LOG_REASON_SLOT_WIN_CONFIRM = 2;
}