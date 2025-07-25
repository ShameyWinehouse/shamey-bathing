
INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `id`, `groupId`, `metadata`, `desc`) VALUES ('soap', 'Soap', '20', '1', 'item_standard', '1', NULL, '1', '{}', 'I\'m not mad at you, I\'m mad at the dirt.');

ALTER TABLE `character_statuses` ADD `cleanliness` INT NOT NULL DEFAULT '100' AFTER `addictions`; 