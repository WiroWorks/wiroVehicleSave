
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `owner` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `plate` varchar(15) COLLATE utf8mb4_bin DEFAULT NULL,
  `vehicle` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  `coords` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  UNIQUE KEY `plate` (`plate`)
)