-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ShuttleSync
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema ShuttleSync
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `ShuttleSync`;
CREATE SCHEMA IF NOT EXISTS `ShuttleSync` DEFAULT CHARACTER SET utf8 ;
USE `ShuttleSync` ;

-- -----------------------------------------------------
-- Table `ShuttleSync`.`Shuttles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Shuttles` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Shuttles` (
  `idShuttles` INT NOT NULL,
  `StartTime` TIME NOT NULL,
  `Available` VARCHAR(5) BINARY NOT NULL DEFAULT 'FALSE',
  PRIMARY KEY (`idShuttles`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`Stops`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Stops` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Stops` (
  `idStops` INT NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idStops`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`Info`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Info` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Info` (
  `Stops_idStops` INT NOT NULL,
  `Shuttles_idShuttles` INT NOT NULL,
  `StopTime` TIME NULL,
  PRIMARY KEY (`Stops_idStops`, `Shuttles_idShuttles`),
  INDEX `fk_Stops_has_Shuttles_Shuttles1_idx` (`Shuttles_idShuttles` ASC) VISIBLE,
  INDEX `fk_Stops_has_Shuttles_Stops_idx` (`Stops_idStops` ASC) VISIBLE,
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

SET SQL_MODE = '';
DROP USER IF EXISTS driver;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'driver' IDENTIFIED BY 'drive';

GRANT UPDATE ON TABLE `ShuttleSync`.`Shuttles` TO 'driver';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `ShuttleSync`.`Shuttles`
-- -----------------------------------------------------
START TRANSACTION;
USE `ShuttleSync`;
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (01, '09:00:00', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (02, '09:01:30', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (03, '09:03:00', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (04, '09:04:30', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (05, '09:06:00', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (06, '09:07:30', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (07, '09:09:00', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (08, '09:10:30', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (09, '09:12:00', 'FALSE');
INSERT INTO `ShuttleSync`.`Shuttles` (`idShuttles`, `StartTime`, `Available`) VALUES (10, '09:13:30', 'FALSE');

COMMIT;


-- -----------------------------------------------------
-- Data for table `ShuttleSync`.`Stops`
-- -----------------------------------------------------
START TRANSACTION;
USE `ShuttleSync`;
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (01, 'SMME/SNS');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (02, 'Retro Cafe');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (03, 'NICE Ground');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (04, 'Concordia 2');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (05, 'Main Office');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (06, 'Girls\' Hostels');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (07, 'Concordia 1');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (08, 'ASAB/SADA');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (09, 'Gate 2');
INSERT INTO `ShuttleSync`.`Stops` (`idStops`, `Name`) VALUES (10, 'HBL');

COMMIT;

