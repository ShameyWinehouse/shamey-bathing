START TRANSACTION;

CREATE TABLE `character_statuses` (
  `id` int(11) NOT NULL,
  `identifier` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `charidentifier` int(11) NOT NULL,
  `addictions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`addictions`)),
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

ALTER TABLE `character_statuses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_identifier` (`identifier`),
  ADD KEY `fk_statuses_charid` (`charidentifier`);

ALTER TABLE `character_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `character_statuses`
  ADD CONSTRAINT `fk_statuses_charid` FOREIGN KEY (`charidentifier`) REFERENCES `characters` (`charidentifier`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_statuses_identifier` FOREIGN KEY (`identifier`) REFERENCES `users` (`identifier`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;