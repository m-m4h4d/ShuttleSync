-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ShuttleSync
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `ShuttleSync` ;

-- -----------------------------------------------------
-- Schema ShuttleSync
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ShuttleSync` DEFAULT CHARACTER SET utf8 ;
SHOW WARNINGS;
USE `ShuttleSync` ;

-- -----------------------------------------------------
-- Table `ShuttleSync`.`Shuttles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Shuttles` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Shuttles` (
  `idShuttles` INT NOT NULL,
  `StartTime` TIME NOT NULL,
  `Available` VARCHAR(5) BINARY NOT NULL DEFAULT 'FALSE',
  `Cycles` INT NULL,
  PRIMARY KEY (`idShuttles`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `ShuttleSync`.`Stops`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Stops` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Stops` (
  `idStops` INT NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Duration` TIME NULL,
  PRIMARY KEY (`idStops`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `ShuttleSync`.`Info`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Info` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Info` (
  `Stops_idStops` INT NOT NULL,
  `Shuttles_idShuttles` INT NOT NULL,
  `StopTime` CHAR NULL,
  `ID` INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`ID`),
  CONSTRAINT `fk_Stops_has_Shuttles_Stops`
    FOREIGN KEY (`Stops_idStops`)
    REFERENCES `ShuttleSync`.`Stops` (`idStops`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Stops_has_Shuttles_Shuttles1`
    FOREIGN KEY (`Shuttles_idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_Stops_has_Shuttles_Shuttles1_idx` ON `ShuttleSync`.`Info` (`Shuttles_idShuttles` ASC) VISIBLE;

SHOW WARNINGS;
CREATE INDEX `fk_Stops_has_Shuttles_Stops_idx` ON `ShuttleSync`.`Info` (`Stops_idStops` ASC) VISIBLE;

SHOW WARNINGS;
CREATE UNIQUE INDEX `ID_UNIQUE` ON `ShuttleSync`.`Info` (`ID` ASC) VISIBLE;

SHOW WARNINGS;
USE `ShuttleSync` ;

-- -----------------------------------------------------
-- procedure show_info
-- -----------------------------------------------------

USE `ShuttleSync`;
DROP procedure IF EXISTS `ShuttleSync`.`show_info`;
SHOW WARNINGS;

DELIMITER $$
USE `ShuttleSync`$$
CREATE PROCEDURE `show_info` (IN stop_name VARCHAR(45))
BEGIN
	SELECT Shuttles_idShuttles AS ShuttleID, StopTime
	FROM Info
	WHERE Stops_idStops = (SELECT idStops FROM Stops WHERE Name = stop_name);
END$$

DELIMITER ;
SHOW WARNINGS;

-- -----------------------------------------------------
-- procedure calculate_time
-- -----------------------------------------------------

USE `ShuttleSync`;
DROP procedure IF EXISTS `ShuttleSync`.`calculate_time`;
SHOW WARNINGS;

DELIMITER $$
USE `ShuttleSync`$$
CREATE PROCEDURE `calculate_time` (IN shuttleID INT, IN stopID INT)
BEGIN
    DECLARE shuttleStartTime TIME;
    DECLARE shuttleCycles INT;
    DECLARE stopDuration TIME;
    DECLARE calculatedStopTime TIME;

    -- Get StartTime and Cycles from Shuttles table
SELECT 
    StartTime, Cycles
INTO shuttleStartTime , shuttleCycles FROM
    Shuttles
WHERE
    idShuttles = shuttleID;

    -- Get Duration from Stops table
SELECT 
    Duration
INTO stopDuration FROM
    Stops
WHERE
    idStops = stopID;

    -- Calculate StopTime (considering one cycle as 15 minutes)
    SET calculatedStopTime = CAST(ADDTIME(stopDuration, ADDTIME(shuttleStartTime, SEC_TO_TIME(shuttleCycles * 15 * 60))) AS CHAR);

    -- Update StopTime in Info table
UPDATE Info 
SET 
    StopTime = calculatedStopTime
WHERE
    Shuttles_idShuttles = shuttleID
        AND Stops_idStops = stopID;
END$$

DELIMITER ;
SHOW WARNINGS;
USE `ShuttleSync`;

DELIMITER $$

USE `ShuttleSync`$$
DROP TRIGGER IF EXISTS `ShuttleSync`.`update_cycles_trigger` $$
SHOW WARNINGS$$
USE `ShuttleSync`$$
CREATE DEFINER = CURRENT_USER TRIGGER `ShuttleSync`.`update_cycles_trigger` AFTER UPDATE ON `Info` FOR EACH ROW
BEGIN
    DECLARE lastStopID INT;

    -- Get the highest idStops from the Stops table
SELECT 
    MAX(idStops)
INTO lastStopID FROM
    Stops;

    -- Check if the updated stop is the last stop
    IF NEW.Stops_idStops = lastStopID THEN
        -- Increment Cycles by 1 for the corresponding shuttle
        UPDATE Shuttles
        SET Cycles = Cycles + 1
        WHERE idShuttles = NEW.Shuttles_idShuttles;
    END IF;
END$$

SHOW WARNINGS$$

USE `ShuttleSync`$$
DROP TRIGGER IF EXISTS `ShuttleSync`.`reset_cycles_trigger` $$
SHOW WARNINGS$$
USE `ShuttleSync`$$
CREATE DEFINER = CURRENT_USER TRIGGER `ShuttleSync`.`reset_cycles_trigger` AFTER UPDATE ON `Info` FOR EACH ROW
BEGIN
DECLARE currentTime TIME;
    DECLARE reset_time TIME;

    -- Set the reset time to 5:00 PM
    SET reset_time = '17:00:00';

    -- Get the current time
    SET currentTime = CURRENT_TIME();

    -- Check if the current time is 5:00 PM
    IF currentTime = reset_time THEN
        -- Reset 'cycles' to zero and 'Available' to 'FALSE' for all shuttles
        UPDATE Shuttles
        SET Cycles = 0, Available = 'FALSE';
    END IF;
END$$

SHOW WARNINGS$$

USE `ShuttleSync`$$
DROP TRIGGER IF EXISTS `ShuttleSync`.`start_cycles_trigger` $$
SHOW WARNINGS$$
USE `ShuttleSync`$$
CREATE DEFINER = CURRENT_USER TRIGGER `ShuttleSync`.`start_cycles_trigger` AFTER UPDATE ON `Info` FOR EACH ROW
BEGIN
	DECLARE currentTime TIME;
    DECLARE start_time TIME;

    -- Set the start time to 9:00 AM
    SET start_time = '09:00:00';

    -- Get the current time
    SET currentTime = CURRENT_TIME();

    -- Check if the current time is 9:00 AM
    IF currentTime = start_time THEN
        -- Reset 'cycles' to NULL and 'Available' to 'TRUE' for all shuttles
        UPDATE Shuttles
        SET Cycles = NULL, Available = 'TRUE';
    END IF;
END$$

SHOW WARNINGS$$

DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS driver;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SHOW WARNINGS;
CREATE USER 'driver' IDENTIFIED BY 'drive';

GRANT UPDATE ON TABLE `ShuttleSync`.`Shuttles` TO 'driver';
SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `ShuttleSync`.`Shuttles`
-- -----------------------------------------------------
START TRANSACTION;
USE `ShuttleSync`;
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (101, '09:00:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (102, '09:01:30', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (103, '09:03:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (104, '09:04:30', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (105, '09:06:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (106, '09:07:30', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (107, '09:09:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (108, '09:10:30', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (109, '09:12:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (110, '09:13:30', 'FALSE', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `ShuttleSync`.`Stops`
-- -----------------------------------------------------
START TRANSACTION;
USE `ShuttleSync`;
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (1, 'Retro Cafe', '00:01:30');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (2, 'NICE Ground', '00:03:00');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (3, 'Concordia 2', '00:04:30');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (4, 'Main Office', '00:06:00');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (5, 'Girls\' Hostels', '00:07:30');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (6, 'Concordia 1', '00:09:00');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (7, 'ASAB/SADA', '00:10:30');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (8, 'Gate 2', '00:12:00');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (9, 'HBL', '00:13:30');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (10, 'SMME/SNS', '00:15:00');

COMMIT;


-- -----------------------------------------------------
-- Data for table `ShuttleSync`.`Info`
-- -----------------------------------------------------
START TRANSACTION;
USE `ShuttleSync`;
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 101, 'a', 1);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 102, 'a', 2);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 103, 'a', 3);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 104, 'a', 4);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 105, 'a', 5);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 106, 'a', 6);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 107, 'a', 7);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 108, 'a', 8);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 109, 'a', 9);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (1, 110, 'a', 10);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 101, 'a', 11);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 102, 'a', 12);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 103, 'a', 13);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 104, 'a', 14);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 105, 'a', 15);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 106, 'a', 16);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 107, 'a', 17);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 108, 'a', 18);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 109, 'a', 19);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (2, 110, 'a', 20);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 101, 'a', 21);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 102, 'a', 22);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 103, 'a', 23);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 104, 'a', 24);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 105, 'a', 25);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 106, 'a', 26);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 107, 'a', 27);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 108, 'a', 28);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 109, 'a', 29);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (3, 110, 'a', 30);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 101, 'a', 31);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 102, 'a', 32);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 103, 'a', 33);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 104, 'a', 34);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 105, 'a', 35);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 106, 'a', 36);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 107, 'a', 37);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 108, 'a', 38);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 109, 'a', 39);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (4, 110, 'a', 40);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 101, 'a', 41);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 102, 'a', 42);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 103, 'a', 43);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 104, 'a', 44);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 105, 'a', 45);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 106, 'a', 46);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 107, 'a', 47);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 108, 'a', 48);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 109, 'a', 49);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (5, 110, 'a', 50);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 101, 'a', 51);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 102, 'a', 52);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 103, 'a', 53);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 104, 'a', 54);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 105, 'a', 55);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 106, 'a', 56);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 107, 'a', 57);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 108, 'a', 58);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 109, 'a', 59);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (6, 110, 'a', 60);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 101, 'a', 61);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 102, 'a', 62);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 103, 'a', 63);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 104, 'a', 64);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 105, 'a', 65);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 106, 'a', 66);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 107, 'a', 67);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 108, 'a', 68);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 109, 'a', 69);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (7, 110, 'a', 70);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 101, 'a', 71);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 102, 'a', 72);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 103, 'a', 73);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 104, 'a', 74);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 105, 'a', 75);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 106, 'a', 76);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 107, 'a', 77);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 108, 'a', 78);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 109, 'a', 79);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (8, 110, 'a', 80);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 101, 'a', 81);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 102, 'a', 82);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 103, 'a', 83);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 104, 'a', 84);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 105, 'a', 85);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 106, 'a', 86);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 107, 'a', 87);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 108, 'a', 88);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 109, 'a', 89);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (9, 110, 'a', 90);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 101, 'a', 91);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 102, 'a', 92);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 103, 'a', 93);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 104, 'a', 94);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 105, 'a', 95);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 106, 'a', 96);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 107, 'a', 97);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 108, 'a', 98);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 109, 'a', 99);
INSERT INTO `ShuttleSync`.`Info` (`Stops_idStops`, `Shuttles_idShuttles`, `StopTime`, `ID`) VALUES (10, 110, 'a', 100);

COMMIT;

