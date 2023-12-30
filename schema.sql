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
  `Available` TINYINT NULL,
  PRIMARY KEY (`idShuttles`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`Retro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Retro` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Retro` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_Retro_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_Retro_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`NICE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`NICE` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`NICE` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_NICE_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_NICE_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`C1`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`C1` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`C1` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_C1_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_C1_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`Hostels`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Hostels` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Hostels` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_Hostels_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_Hostels_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`Library`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Library` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Library` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_Library_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_Library_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`C2`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`C2` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`C2` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_C2_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_C2_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`ASAB`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`ASAB` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`ASAB` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_ASAB_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_ASAB_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`SMME`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`SMME` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`SMME` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_Stop1_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_Stop1_Shuttles040`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`HBL`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`HBL` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`HBL` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_HBL_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_HBL_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShuttleSync`.`Gate2`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShuttleSync`.`Gate2` ;

CREATE TABLE IF NOT EXISTS `ShuttleSync`.`Gate2` (
  `idShuttles` INT NOT NULL,
  `StopTime` TIME NOT NULL,
  INDEX `fk_Gate2_Shuttles_idx` (`idShuttles` ASC) VISIBLE,
  PRIMARY KEY (`idShuttles`),
  CONSTRAINT `fk_Gate2_Shuttles`
    FOREIGN KEY (`idShuttles`)
    REFERENCES `ShuttleSync`.`Shuttles` (`idShuttles`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
