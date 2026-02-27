-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Hôte : mysql:3306
-- Généré le : jeu. 26 fév. 2026 à 14:55
-- Version du serveur : 8.0.45
-- Version de PHP : 8.0.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `drinkks`
--

-- --------------------------------------------------------

--
-- Structure de la table `doctrine_migration_versions`
--

CREATE TABLE `doctrine_migration_versions` (
  `version` varchar(191) NOT NULL,
  `executed_at` datetime DEFAULT NULL,
  `execution_time` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `doctrine_migration_versions`
--

INSERT INTO `doctrine_migration_versions` (`version`, `executed_at`, `execution_time`) VALUES
('DoctrineMigrations\\Version20260222005317', '2026-02-22 00:53:21', 99);

-- --------------------------------------------------------

--
-- Structure de la table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` int NOT NULL,
  `refresh_token` varchar(128) NOT NULL,
  `valid` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `revoked` tinyint NOT NULL,
  `user_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`id`, `refresh_token`, `valid`, `created_at`, `revoked`, `user_id`) VALUES
(1, 'NJIphFcaywKxYjH7Fs1Apj47v9BlFuNg8kBTsbcUWSc', '2026-03-27 01:02:26', '2026-02-25 01:02:26', 1, 1),
(2, 'WyO3NsWUnpewPmdcJbly6kYNTyF_GbvKUhax1dJNCdU', '2026-03-27 01:02:47', '2026-02-25 01:02:47', 1, 1),
(3, 'H0sv6nsbhbd7HPX0ejVnat_smGWj8Kz0244yMonlU-Q', '2026-03-27 01:02:53', '2026-02-25 01:02:53', 1, 6),
(4, 'XuPGg5r9vjkHpQGA70YWQUidV9-EL6YfubVvPZmQcwA', '2026-03-27 01:08:09', '2026-02-25 01:08:09', 1, 6),
(5, 'hRHWgTHzOyU8zAiKALWOiCEmmNoZxe_iN33FB089E3I', '2026-03-27 01:09:56', '2026-02-25 01:09:56', 1, 6),
(6, '0vvg8XpDbRcoCzi1qQcmM-UVKIbwjaizhVWK40eXNfY', '2026-03-27 01:10:34', '2026-02-25 01:10:34', 1, 6),
(7, 'xT38G2WuyF20sBoj0zPKCl5eZQyFqJwn61Y0tZSfieg', '2026-03-27 12:56:13', '2026-02-25 12:56:13', 1, 6),
(8, 'LzXomcZWn172i_O6C3uFadjjWsaXi9cOKPir1UdLngs', '2026-03-27 12:56:35', '2026-02-25 12:56:35', 1, 6),
(9, 'cM6_WTm9wUw6ZjXSIWFash7zr0NF6WmQuAiAZ3mg_XY', '2026-03-27 13:16:53', '2026-02-25 13:16:53', 1, 1),
(10, 'm-txw81Rssgeiod5wvw__FQzRihPv1iRVuOyg1qViMo', '2026-03-27 13:17:23', '2026-02-25 13:17:23', 1, 1),
(11, 'dsZJ0MNzEidv7SwPZAxiyzs6Fjxb3rWpeOpQlW0Jc8w', '2026-03-27 13:24:17', '2026-02-25 13:24:17', 1, 1),
(12, 'zc9xHpMVpnh6lMqZGpcutNlT0RzAS1h6h10Vsrgl6Aw', '2026-03-27 13:39:03', '2026-02-25 13:39:03', 1, 6),
(13, '8C8hz8IEN0douVDtAULw0efivLaXdHIB_SiExBN4HP8', '2026-03-27 13:40:19', '2026-02-25 13:40:19', 1, 6),
(14, 'vel7m1AQnPQN1aXO2TYraMFEq_xHJ0DG9934h_Q2vqk', '2026-03-27 13:41:30', '2026-02-25 13:41:30', 1, 6),
(15, 'NZlLuVjOMrNw__vgDnWu_MlT58jRzMPIPpUOTcMTBrw', '2026-03-27 13:43:18', '2026-02-25 13:43:18', 1, 6),
(16, 'upu91A_kh0oNM5dbSELQ0GPJixxLvfQTj1mRLDmqFZs', '2026-03-27 13:45:25', '2026-02-25 13:45:25', 1, 6),
(17, 'NlLFsVbS34x2Pi76fe73gVSIqtRwKgwu-wO1ld1HC2g', '2026-03-27 13:45:53', '2026-02-25 13:45:53', 1, 6),
(18, 'Mn9RKXGOh25PtoZfV6e8B5RbhdnWfRxTH6FXrJ1XlCs', '2026-03-27 13:47:00', '2026-02-25 13:47:00', 1, 6),
(19, 'PK8SfzKH05tb5OT189GCRfWXsua72vME1ZbYX7rRc2U', '2026-03-27 13:47:27', '2026-02-25 13:47:27', 1, 6),
(20, 'Ay__xH7XzAOt6hhM93RW-sDP7BZ1WeT_BwhAJXZ0-24', '2026-03-27 13:48:11', '2026-02-25 13:48:11', 1, 6),
(21, 'ixIa_swib9x5BYvkqmcyO9sRyDIZFHfUpEsdDwL8qQ0', '2026-03-27 13:58:40', '2026-02-25 13:58:40', 1, 6),
(22, '4toZJMgvoKQ4_lWFXPuOhcXsqJXbzx_Ay2NcJ_1lzE8', '2026-03-27 13:59:12', '2026-02-25 13:59:12', 1, 6),
(23, 'mnoSTe-LfzfULGhXwViLIRcgyPRXSKrJHCQywYAg3eU', '2026-03-27 14:00:42', '2026-02-25 14:00:42', 1, 6),
(24, '-qVFhc2rzBy0DPEg9D7vJgGFsOrX7O0NjgPAbOE8qn8', '2026-03-27 14:01:19', '2026-02-25 14:01:19', 1, 6),
(25, 'AIW07yUxCRln7FOjbEGedwgH4AifaTxKhYbOdJnTCcQ', '2026-03-27 14:06:42', '2026-02-25 14:06:42', 1, 6),
(26, 'H2ruhEgVVGT1-MdlzplJtf-SWj3aCoYPQuta8RBgSbk', '2026-03-27 14:08:20', '2026-02-25 14:08:20', 1, 6),
(27, 'uTETvzHrWELbb9ahPSgl93QUf-aINAOWTaywtyG6eQI', '2026-03-27 14:08:46', '2026-02-25 14:08:46', 1, 6),
(28, 'zpYJYJw9Je_rU7n78RLROkT1AkxOuOfkS9aOVN14Wgs', '2026-03-27 14:08:46', '2026-02-25 14:08:46', 1, 6),
(29, 'mbtKG2ambcOnXEZ4UnkfsNuRD0Ko7Yd1wn_bBuntesU', '2026-03-27 14:09:19', '2026-02-25 14:09:19', 1, 6),
(30, 'h67frDT3mdjTLqykKhWdBgnE9Ek2Z96fuymiL6Z5sJQ', '2026-03-27 14:11:58', '2026-02-25 14:11:58', 1, 6),
(31, 'hbumpNYhcNFIPPj0MdEVj7t44-yhjYQdqF0jRI5fSOU', '2026-03-27 14:12:29', '2026-02-25 14:12:29', 1, 6),
(32, '_2RAhIBodWnQV6IUZu0hAdquUrIB1WJHRzj0qN4kyv8', '2026-03-27 14:13:01', '2026-02-25 14:13:01', 0, 6),
(33, 'akVgH-yRo0ayNHJ3hkEZLR1HNi7bgqJwYMcHY8yPwXw', '2026-03-27 14:13:11', '2026-02-25 14:13:11', 1, 1),
(34, 'q5pURzdt3roBUuHzRxdJEd0_EFBy3wYUNP1ndpg7OFA', '2026-03-27 14:14:41', '2026-02-25 14:14:41', 1, 1),
(35, 'Mpi4i7-UIvinNjO1eIrosVpJDMLqcq1RZTyMHOrP2lQ', '2026-03-27 14:15:37', '2026-02-25 14:15:37', 1, 1),
(36, '69nHNrZJ2YAvDfUm8AvSiYbjCN_1CYkVGTPtKyI7rDs', '2026-03-27 14:36:08', '2026-02-25 14:36:08', 0, 1),
(37, 'rIuPHN4F2Ew6UA-JLnqG-riU-BqhPrxouEJEG6hCL18', '2026-03-27 15:21:25', '2026-02-25 15:21:25', 0, 1),
(38, '7y8VRHHnGIfy6s_Nh5sVxTBBtPU41_dQfCSOzZm1BqQ', '2026-03-27 15:21:54', '2026-02-25 15:21:54', 0, 1),
(39, 'ymF8pSC3_aiaXprLL9dSPD1mYRvhEvSIY6LW5QcLy10', '2026-03-27 15:24:32', '2026-02-25 15:24:32', 0, 1),
(40, 'yGNSJDhX-GCZp7teJlLOkqn1aPwGtoTxai-JR6YZ0Gc', '2026-03-27 15:28:35', '2026-02-25 15:28:35', 0, 1),
(41, 'kBa6Et8ZTGFA20CQ14M3pG9xOdfMblQltH9jvBxV82o', '2026-03-27 15:53:50', '2026-02-25 15:53:50', 0, 1),
(42, 'eyhp6Hz9C269myA6rGZbEHxvT1BXmb9dch3EA6J-HME', '2026-03-27 15:59:44', '2026-02-25 15:59:44', 1, 1),
(43, 'tV6UjDaeFAVXb1Z_lWHtlHq1_eeMWr-feRsZDh0o1No', '2026-03-27 16:00:08', '2026-02-25 16:00:08', 1, 1),
(44, 'm2EbvtCaT0OtOAkyoG58mgRIkN0xcYLN9ZmBPfO1JDQ', '2026-03-27 16:03:26', '2026-02-25 16:03:26', 1, 1),
(45, 'wXgqIfSsnamcTr6_KWYj-5A66g29yT3Qr7lea2d_LEM', '2026-03-27 16:07:07', '2026-02-25 16:07:07', 0, 1),
(46, 'eCKoM3TpRMPu5Tj4aS1iNJqHFCJRxdV7pdeEFoWcepo', '2026-03-27 16:13:34', '2026-02-25 16:13:34', 1, 1),
(47, 'sySU6h1zxuwFRqdl5zWBfSC1Hcodogkzlwar8Bg5los', '2026-03-27 16:17:12', '2026-02-25 16:17:12', 0, 1),
(48, 'hohzi_cdiBkGixO3kHFbBZGPVJdqiohf0uTKYHBvQyo', '2026-03-27 16:18:28', '2026-02-25 16:18:28', 1, 1),
(49, '4auHjTmERAMum9dKJEJ4YjwQ0DuE-hFK_0R1xg0Xk4w', '2026-03-27 16:22:29', '2026-02-25 16:22:29', 1, 1),
(50, 'aJoAvNAS2S8r-cn94MiTaz6cZFWgUw11-ea55EyUou4', '2026-03-27 16:23:39', '2026-02-25 16:23:39', 1, 1),
(51, 'wP_nOMuduaHDg1oiZS34RGnpaF0atPXh6eQy2FSI2c4', '2026-03-27 16:26:39', '2026-02-25 16:26:39', 1, 1),
(52, '6poa3CgiejbpBfC1tdM-EwIzFeljNR7Q8YuDfnUe5nM', '2026-03-27 16:28:19', '2026-02-25 16:28:19', 1, 1),
(53, 'NmW13zdY4s5fbjFzjHNa5WMgAiYktdn-xo63RVrv7GA', '2026-03-27 17:47:37', '2026-02-25 17:47:37', 1, 1),
(54, 'JzUWUC7UeIdJ_ZjIdmtL6qabUBGwUYByZ_Iii7LmrpM', '2026-03-27 17:55:35', '2026-02-25 17:55:35', 1, 1),
(55, 'e5vderLSXpBPp1cE3vzE_U8sQnAkfCerYXcJmem7WkA', '2026-03-27 18:00:15', '2026-02-25 18:00:15', 1, 1),
(56, 'x7wPAKPDTZjYqvU35Cc_RljQOR8XSd34O3lMFnM7aeM', '2026-03-27 18:05:10', '2026-02-25 18:05:10', 1, 1),
(57, 'GDuA3sT18OY-phZtV0yyd6n9opQnIkGcir72MuIr9Kg', '2026-03-27 18:05:40', '2026-02-25 18:05:40', 0, 1),
(58, '0b0Xyt6yWhsgUmv00LgETUBAiVXzhpxg1WGXrSZyiLQ', '2026-03-27 18:11:18', '2026-02-25 18:11:18', 1, 1),
(59, 'JS8nKqtNdxZm5al_diV8aFUNmTM2ikefPeqME-43z2M', '2026-03-27 18:12:06', '2026-02-25 18:12:06', 1, 1),
(60, '3mxRngXM2i00MfN1CL8dvEuJ0O-Vvse7bzUtfQva600', '2026-03-27 18:57:53', '2026-02-25 18:57:53', 1, 1),
(61, 'ujxPjhOdTVX_oQuVzKj6GdwJtU-VW038v6hpvBqKW8o', '2026-03-27 19:00:14', '2026-02-25 19:00:14', 1, 1),
(62, 'YS0cYPOh439lckW9Ix4-hyvNMfLqxst5NIMHiTOPpcU', '2026-03-27 21:11:02', '2026-02-25 21:11:02', 1, 1),
(63, 'rMI4TyxTspWXYjo4qUowXqvWOILbgkrpXOXQXkABseQ', '2026-03-27 21:11:38', '2026-02-25 21:11:38', 1, 1),
(64, 'lMQkZtoSHPWmoRwnEObNBy5ASGKbWsV3bcdO-WS0cQ8', '2026-03-27 21:12:08', '2026-02-25 21:12:08', 1, 1),
(65, 'MMx1f2n9gyC2jxMNjxiEgaMU1dhi-6dEhAsapu6Huag', '2026-03-27 21:13:01', '2026-02-25 21:13:01', 1, 1),
(66, 'H1v-FS0iSJjWoZQAsZxjueisHWBE8eU2UosGqyqX5y0', '2026-03-27 21:13:42', '2026-02-25 21:13:42', 1, 1),
(67, '4m91LBLid9H_r5Qq2wd9nCNIwy9JjheQZ-CCKqTVoH8', '2026-03-27 21:14:07', '2026-02-25 21:14:07', 1, 1),
(68, '2PvZ1C02lH_M58GmzI9AHEMQgM5VdQY7hr96e9RtgWE', '2026-03-27 21:42:53', '2026-02-25 21:42:53', 0, 1),
(69, 'rJcVn1B-Iy40CzOey5SKV8hMNYzY4u4-CVhBfhyu7dc', '2026-03-27 21:50:11', '2026-02-25 21:50:11', 0, 1),
(70, '66SB44XALumlaj88Q9pB8vRfRkDoAQrRjyMoshzrU-Y', '2026-03-27 21:51:42', '2026-02-25 21:51:42', 0, 1),
(71, 'QkbytBI58-sCluS1nMFheFkpxHXuPbVkX_atkfQ0rMc', '2026-03-27 21:51:52', '2026-02-25 21:51:52', 0, 1),
(72, '3v79hJ0XlC5EFdFI-QdxR0DcyHNFzF7lbh0a6UjOnxs', '2026-03-27 21:54:56', '2026-02-25 21:54:56', 0, 1),
(73, 'XopqmBd2MkEP9DCldfT_lCRznNuA6FiHwQ2IMlytKss', '2026-03-27 22:28:50', '2026-02-25 22:28:50', 0, 1),
(74, 'RHLNVoEkyiIoXQtGH0YxCE2ORSInghMGbmKIxTFToDA', '2026-03-27 22:31:15', '2026-02-25 22:31:15', 0, 1),
(75, '7g-LGYNBkyU0HpmFPB4wDhV7w4Z8_sD8MaqPWP1J62U', '2026-03-27 22:35:37', '2026-02-25 22:35:37', 0, 1),
(76, 'x9cHRShfrKYEPeNrrXpxZj6yqdphm_1vSOqAy73A5t4', '2026-03-27 22:37:33', '2026-02-25 22:37:33', 0, 1),
(77, 'xZ1iSkuRhHcvRxfbVi8FtyEWP0xmY0H5KhBcIvau14E', '2026-03-27 22:47:55', '2026-02-25 22:47:55', 1, 1),
(78, 'GRM8UFP3A8ZsgihDxCdrL2OnhtbnmK1laAf4fXV_Ypw', '2026-03-27 23:51:15', '2026-02-25 23:51:15', 1, 1),
(79, '8IhRS8SbPEaarbHL1_peb0HcWAsT4fvQN3Dm_HFMhmM', '2026-03-27 23:51:32', '2026-02-25 23:51:32', 0, 1),
(80, 'uUFu9ao9W0nce4BLLo3D2JmSwwAVKtdw_m8MoVb1C9s', '2026-03-28 14:21:41', '2026-02-26 14:21:41', 0, 1),
(81, '1AwWpirsxBTfTn3o0W6yomkOrq1YvVTwn96N5_qGX0I', '2026-03-28 14:23:38', '2026-02-26 14:23:38', 0, 1);

-- --------------------------------------------------------

--
-- Structure de la table `room`
--

CREATE TABLE `room` (
  `id_room` int NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `id_venue` int NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user`
--

CREATE TABLE `user` (
  `id` int NOT NULL,
  `uid` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `auth_uid` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `roles` json NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about_me` longtext COLLATE utf8mb4_unicode_ci,
  `gender` int DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `has_photo` tinyint DEFAULT '0',
  `status` int NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `first_access` int DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `user`
--

INSERT INTO `user` (`id`, `uid`, `auth_uid`, `roles`, `email`, `username`, `password`, `display_name`, `about_me`, `gender`, `birthdate`, `has_photo`, `status`, `created_at`, `updated_at`, `first_access`) VALUES
(1, '7ff34973-c136-42fa-b822-cd1af8446b8d', 'AtJbLX0UgIcpiaWCZNnc9JdLzff1', '[\"ROLE_ADMIN\", \"ROLE_USER\"]', 'user@example.com', 'user@example.com', '$2y$13$zfuUMzOXmPNOvSIXrZHHIOT2wdnjyK1mxeSC/YNLTjc0k6ZUQv8am', 'usejjjjj', 'cifiggnckgxxx\nmmmmmmkkjhhynnnnxxx', 3, '1973-09-19', 1, 1, '2025-10-27 14:33:19', '2026-02-25 14:14:42', 0),
(6, '894f7d75-09db-42a1-adc8-10827e4f7f91', 'SEwLAgunAcQCzrC4tixVRXosjPi2', '[\"ROLE_USER\"]', 'ssisengrath@gmail.com', 'ssisengrath@gmail.com', '$2y$13$GFQsn1v5G3mTK8GlwaXFaufZ6//kASKIPAvJyX8O0vmQxBOaxlPDa', 'Souvanny Sisengrath', 'jjjhuu', 1, '2005-02-09', 1, 1, '2026-02-25 01:02:53', '2026-02-25 14:09:31', 0);

-- --------------------------------------------------------

--
-- Structure de la table `venue`
--

CREATE TABLE `venue` (
  `id_venue` int NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `type` int DEFAULT NULL,
  `rank` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `venue`
--

INSERT INTO `venue` (`id_venue`, `uuid`, `name`, `description`, `type`, `rank`, `created_at`, `updated_at`) VALUES
(1, '137d2889-1266-11f1-bbbb-0242ac1a0002', 'Le Lounge Étoilé', 'Ambiance lounge avec vue sur les étoiles', 1, 501, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(2, '137d2e15-1266-11f1-bbbb-0242ac1a0002', 'La Cave Jazz', 'Ambiance intime et musique live', 1, 971, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(3, '137d3012-1266-11f1-bbbb-0242ac1a0002', 'La Brasserie Art Déco', 'Ambiance années 20 et cocktails classiques', 1, 351, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(4, '137d3093-1266-11f1-bbbb-0242ac1a0002', 'L\'Atelier des Saveurs', 'Cocktails moléculaires et expériences sensorielles', 1, 843, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(5, '137d30e3-1266-11f1-bbbb-0242ac1a0002', 'The Speakeasy', 'Bar clandestin des années 20, entrée discrète', 1, 162, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(6, '137d31a7-1266-11f1-bbbb-0242ac1a0002', 'Le Salon de Thé', 'Ambiance cosy et pâtisseries fines', 1, 278, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(7, '137d32a6-1266-11f1-bbbb-0242ac1a0002', 'Le Glacier', 'Bar de glace éphémère à -10°C', 1, 907, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(8, '137d3308-1266-11f1-bbbb-0242ac1a0002', 'Le Bar à Jeux', 'Jeux de société et bières locales', 1, 698, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(9, '137d33bb-1266-11f1-bbbb-0242ac1a0002', 'Le Bar du Port', 'Son des vagues et cocktails fruités', 2, 768, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(10, '137d36e4-1266-11f1-bbbb-0242ac1a0002', 'Le Bistrot Parisien', 'Charme français et vins de qualité', 2, 748, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(11, '137d38ae-1266-11f1-bbbb-0242ac1a0002', 'Le Bar à Bulles', 'Champagnes et vins pétillants', 2, 432, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(12, '137d390b-1266-11f1-bbbb-0242ac1a0002', 'Le Yacht Club', 'Ambiance nautique et fruits de mer', 2, 918, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(13, '137d3994-1266-11f1-bbbb-0242ac1a0002', 'Le Caveau', 'Cave voûtée et vins millésimés', 2, 294, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(14, '137d3a20-1266-11f1-bbbb-0242ac1a0002', 'Le Cyclade', 'Ambiance des îles grecques et ouzo', 2, 714, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(15, '137d3a7a-1266-11f1-bbbb-0242ac1a0002', 'Le Pressoir', 'Cidres et jus de pommes artisanaux', 2, 689, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(16, '137d3ab6-1266-11f1-bbbb-0242ac1a0002', 'Le Millésime', 'Bar à vins avec cave apparente', 2, 301, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(17, '137d3af6-1266-11f1-bbbb-0242ac1a0002', 'Le Rooftop Urbain', 'Vue panoramique sur la skyline', 3, 438, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(18, '137d3b34-1266-11f1-bbbb-0242ac1a0002', 'Le Château de Verre', 'Architecture moderne et soirées élégantes', 3, 286, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(19, '137d3b79-1266-11f1-bbbb-0242ac1a0002', 'Le Loft Industriel', 'Style new-yorkais et musique électro', 3, 114, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(20, '137d3bc8-1266-11f1-bbbb-0242ac1a0002', 'La Voûte Céleste', 'Plafond étoilé et ambiance romantique', 3, 714, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(21, '137d3c0a-1266-11f1-bbbb-0242ac1a0002', 'Le Baroque', 'Décoration opulente et musique classique', 3, 229, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(22, '137d3c47-1266-11f1-bbbb-0242ac1a0002', 'Le Dock', 'Bar portuaire et bières artisanales', 3, 999, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(23, '137d3ca6-1266-11f1-bbbb-0242ac1a0002', 'Le Studio', 'Ambiance cinéma et cocktails de scène', 3, 310, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(24, '137d3d31-1266-11f1-bbbb-0242ac1a0002', 'L\'Opéra', 'Ambiance théâtrale et cocktails de scène', 3, 553, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(25, '137d3d84-1266-11f1-bbbb-0242ac1a0002', 'Le Club Privé', 'Accès exclusif, ambiance feutrée', 4, 832, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(26, '137d3dc6-1266-11f1-bbbb-0242ac1a0002', 'Le Sky Bar', 'Cocktails et vue imprenable sur la ville', 4, 501, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(27, '137d3e07-1266-11f1-bbbb-0242ac1a0002', 'Le 7ème Ciel', 'Bar perché au 7ème étage avec vue dégagée', 4, 7, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(28, '137d412c-1266-11f1-bbbb-0242ac1a0002', 'Le Refuge Alpin', 'Décor montagnard et vin chaud', 4, 533, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(29, '137d4209-1266-11f1-bbbb-0242ac1a0002', 'L\'Observatoire', 'Télescopes et cocktails astronomiques', 4, 641, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(30, '137d4252-1266-11f1-bbbb-0242ac1a0002', 'Le Penthouse', 'Dernier étage avec piscine à débordement', 4, 608, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(31, '137d429a-1266-11f1-bbbb-0242ac1a0002', 'Le Nid', 'Cocon suspendu dans les arbres', 4, 117, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(32, '137d444b-1266-11f1-bbbb-0242ac1a0002', 'La Galerie', 'Exposition d\'art et vernissages', 4, 760, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(33, '137d4495-1266-11f1-bbbb-0242ac1a0002', 'Le Garden Tropical', 'Jardin virtuel avec cocktails exotiques', 5, 450, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(34, '137d45e9-1266-11f1-bbbb-0242ac1a0002', 'Le Tiki Bar', 'Ambiance polynésienne et cocktails exotiques', 5, 968, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(35, '137d477a-1266-11f1-bbbb-0242ac1a0002', 'La Plage Éphémère', 'Sable fin et cocktails de plage', 5, 489, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(36, '137d47d9-1266-11f1-bbbb-0242ac1a0002', 'Le Jardin Secret', 'Cachet intimiste et plantes exotiques', 5, 541, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(37, '137d4828-1266-11f1-bbbb-0242ac1a0002', 'Le Comptoir Marocain', 'Ambiance orientale et thés à la menthe', 5, 236, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(38, '137d487f-1266-11f1-bbbb-0242ac1a0002', 'La Terrasse Fleurie', 'Jardin suspendu et cocktails floraux', 5, 559, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(39, '137d48c4-1266-11f1-bbbb-0242ac1a0002', 'La Forêt Enchantée', 'Décor forestier et cocktails aux plantes', 5, 84, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(40, '137d4909-1266-11f1-bbbb-0242ac1a0002', 'Le Récif', 'Aquarium géant et cocktails marins', 5, 742, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(41, '137d494d-1266-11f1-bbbb-0242ac1a0002', 'Le Whisky Lounge', 'Collection de whiskys rares et fauteuils en cuir', 6, 458, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(42, '137d4995-1266-11f1-bbbb-0242ac1a0002', 'La Distillerie', 'Cocktails maison avec spiritueux artisanaux', 6, 62, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(43, '137d49de-1266-11f1-bbbb-0242ac1a0002', 'Le Velvet', 'Ambiance chic et musique lounge', 6, 939, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(44, '137d4a23-1266-11f1-bbbb-0242ac1a0002', 'Le Bazar', 'Décoration éclectique du monde entier', 6, 506, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(45, '137d4a6a-1266-11f1-bbbb-0242ac1a0002', 'Le Vaisseau', 'Décoration futuriste et cocktails moléculaires', 6, 712, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(46, '137d4b60-1266-11f1-bbbb-0242ac1a0002', 'Le Rétro', 'Décoration vintage et cocktails oubliés', 6, 44, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(47, '137d4bae-1266-11f1-bbbb-0242ac1a0002', 'Le Sanctuaire', 'Ambiance zen et cocktails sans alcool', 6, 84, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(48, '137d4bfc-1266-11f1-bbbb-0242ac1a0002', 'Le Lodge', 'Ambiance safari et cocktails exotiques', 6, 285, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(49, '137d4c4b-1266-11f1-bbbb-0242ac1a0002', 'Le Montmartre', 'Ambiance bohème et artists', 6, 173, '2026-02-25 16:21:44', '2026-02-25 16:21:44'),
(50, '137d4c96-1266-11f1-bbbb-0242ac1a0002', 'La Casa', 'Ambiance latina et cocktails tequila', 6, 10, '2026-02-25 16:21:44', '2026-02-25 16:21:44');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `doctrine_migration_versions`
--
ALTER TABLE `doctrine_migration_versions`
  ADD PRIMARY KEY (`version`);

--
-- Index pour la table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_9BACE7E1C74F2195` (`refresh_token`),
  ADD KEY `IDX_9BACE7E1A76ED395` (`user_id`);

--
-- Index pour la table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`id_room`),
  ADD UNIQUE KEY `uuid` (`uuid`);

--
-- Index pour la table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uid` (`uid`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `auth_uid` (`auth_uid`);

--
-- Index pour la table `venue`
--
ALTER TABLE `venue`
  ADD PRIMARY KEY (`id_venue`),
  ADD UNIQUE KEY `uuid` (`uuid`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT pour la table `room`
--
ALTER TABLE `room`
  MODIFY `id_room` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user`
--
ALTER TABLE `user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `venue`
--
ALTER TABLE `venue`
  MODIFY `id_venue` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `FK_9BACE7E1A76ED395` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
