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
  `StopTime` TIME NULL,
  PRIMARY KEY (`Stops_idStops`, `Shuttles_idShuttles`),
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
USE `ShuttleSync` ;

-- -----------------------------------------------------
-- procedure calculate_time
-- -----------------------------------------------------

USE `ShuttleSync`;
DROP procedure IF EXISTS `ShuttleSync`.`calculate_time`;
SHOW WARNINGS;

DELIMITER $$
USE `ShuttleSync`$$
CREATE PROCEDURE `calculate_time` ()
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
    SET calculatedStopTime = ADDTIME(shuttleStartTime, SEC_TO_TIME(shuttleCycles * 15 * 60));

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
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (01, '09:00:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (02, '09:01:30', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (03, '09:03:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (04, '09:04:30', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (05, '09:06:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (06, '09:07:30', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (07, '09:09:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (08, '09:10:30', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (09, '09:12:00', 'FALSE', NULL);
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`, `Cycles`) VALUES (10, '09:13:30', 'FALSE', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `ShuttleSync`.`Stops`
-- -----------------------------------------------------
START TRANSACTION;
USE `ShuttleSync`;
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (01, 'SMME/SNS', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (02, 'Retro Cafe', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (03, 'NICE Ground', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (04, 'Concordia 2', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (05, 'Main Office', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (06, 'Girls\' Hostels', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (07, 'Concordia 1', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (08, 'ASAB/SADA', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (09, 'Gate 2', NULL);
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`, `Duration`) VALUES (10, 'HBL', NULL);

COMMIT;

