-- -----------------------------------------------------
-- ShuttleSync database
--
-- Run with the mysql client (DELIMITER is a client command):
--   mysql -h <host> -P <port> -u <user> -p < schema.sql
--
-- Campus times are Pakistan Standard Time (UTC+05:00, no DST). The API
-- passes the campus time into next_arrivals(), so ETAs do not depend on the
-- database server's own time zone.
-- -----------------------------------------------------

DROP SCHEMA IF EXISTS `ShuttleSync`;
CREATE SCHEMA `ShuttleSync` DEFAULT CHARACTER SET utf8mb4;
USE `ShuttleSync`;

-- -----------------------------------------------------
-- Table `Shuttles`
-- -----------------------------------------------------
CREATE TABLE `Shuttles` (
  `idShuttles` INT NOT NULL,
  `StartTime` TIME NOT NULL,
  `Available` BOOLEAN NOT NULL DEFAULT TRUE,
  `Cycles` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`idShuttles`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `Stops`
-- Duration is the offset from a shuttle's StartTime at which it reaches
-- this stop on every loop of the route.
-- -----------------------------------------------------
CREATE TABLE `Stops` (
  `idStops` INT NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Duration` TIME NULL,
  PRIMARY KEY (`idStops`),
  UNIQUE INDEX `Name_UNIQUE` (`Name`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `Info` (which shuttles serve which stops)
-- -----------------------------------------------------
CREATE TABLE `Info` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Stops_idStops` INT NOT NULL,
  `Shuttles_idShuttles` INT NOT NULL,
  `StopTime` TIME NULL,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `stop_shuttle_UNIQUE` (`Stops_idStops`, `Shuttles_idShuttles`),
  INDEX `fk_Stops_has_Shuttles_Shuttles1_idx` (`Shuttles_idShuttles`),
  CONSTRAINT `fk_Stops_has_Shuttles_Stops`
    FOREIGN KEY (`Stops_idStops`)
    REFERENCES `Stops` (`idStops`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Stops_has_Shuttles_Shuttles1`
    FOREIGN KEY (`Shuttles_idShuttles`)
    REFERENCES `Shuttles` (`idShuttles`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Procedures
-- -----------------------------------------------------
DELIMITER $$

-- Last recorded stop time of every shuttle at a stop.
CREATE PROCEDURE `show_info` (IN stop_name VARCHAR(45))
BEGIN
    SELECT i.Shuttles_idShuttles AS ShuttleID, i.StopTime
    FROM Info i
    JOIN Stops s ON s.idStops = i.Stops_idStops
    WHERE s.Name = stop_name
    ORDER BY i.Shuttles_idShuttles;
END$$

-- Records in Info when a shuttle reaches a stop on its current cycle
-- (one cycle of the route is 15 minutes).
CREATE PROCEDURE `calculate_time` (IN shuttleID INT, IN stopID INT)
BEGIN
    DECLARE shuttleStartTime TIME;
    DECLARE shuttleCycles INT;
    DECLARE stopDuration TIME;

    SELECT StartTime, Cycles
    INTO shuttleStartTime, shuttleCycles
    FROM Shuttles
    WHERE idShuttles = shuttleID;

    SELECT COALESCE(Duration, '00:00:00')
    INTO stopDuration
    FROM Stops
    WHERE idStops = stopID;

    UPDATE Info
    SET StopTime = ADDTIME(
            ADDTIME(shuttleStartTime, SEC_TO_TIME(COALESCE(shuttleCycles, 0) * 15 * 60)),
            stopDuration)
    WHERE Shuttles_idShuttles = shuttleID
      AND Stops_idStops = stopID;
END$$

-- Next arrival of every shuttle serving a stop, as seen at `atTime`.
-- A shuttle reaches the stop at StartTime + Duration + k * 15 min for
-- k = 0, 1, 2, ... until service ends at 17:00. ArrivalTime and
-- SecondsUntil are NULL once a shuttle has no more arrivals today.
CREATE PROCEDURE `next_arrivals` (IN stopID INT, IN atTime TIME)
BEGIN
    DECLARE cycleSec INT DEFAULT 15 * 60;
    DECLARE serviceEndSec INT DEFAULT TIME_TO_SEC('17:00:00');
    DECLARE nowSec INT DEFAULT TIME_TO_SEC(atTime);

    SELECT ShuttleID,
           StartTime,
           Available,
           IF(nextSec <= serviceEndSec, SEC_TO_TIME(nextSec), NULL) AS ArrivalTime,
           IF(nextSec <= serviceEndSec, nextSec - nowSec, NULL) AS SecondsUntil
    FROM (
        SELECT ShuttleID, StartTime, Available,
               firstSec + GREATEST(0, CEIL((nowSec - firstSec) / cycleSec)) * cycleSec AS nextSec
        FROM (
            SELECT sh.idShuttles AS ShuttleID,
                   sh.StartTime,
                   sh.Available,
                   TIME_TO_SEC(sh.StartTime) + TIME_TO_SEC(COALESCE(st.Duration, '00:00:00')) AS firstSec
            FROM Info i
            JOIN Stops st ON st.idStops = i.Stops_idStops
            JOIN Shuttles sh ON sh.idShuttles = i.Shuttles_idShuttles
            WHERE i.Stops_idStops = stopID
        ) base
    ) arrivals
    ORDER BY ArrivalTime IS NULL, SecondsUntil, ShuttleID;
END$$

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

-- Recording a stop time at the last stop of the route completes a cycle.
CREATE TRIGGER `update_cycles_trigger` AFTER UPDATE ON `Info` FOR EACH ROW
BEGIN
    IF NEW.Stops_idStops = (SELECT MAX(idStops) FROM Stops)
       AND NOT (NEW.StopTime <=> OLD.StopTime) THEN
        UPDATE Shuttles
        SET Cycles = Cycles + 1
        WHERE idShuttles = NEW.Shuttles_idShuttles;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- Daily schedule (needs event_scheduler = ON, the MySQL 8 default).
-- STARTS is read in the session time zone, so pin it to campus time.
-- -----------------------------------------------------
SET @OLD_TIME_ZONE = @@SESSION.time_zone;
SET time_zone = '+05:00';

CREATE EVENT `start_service_event`
ON SCHEDULE EVERY 1 DAY STARTS TIMESTAMP(CURRENT_DATE, '09:00:00')
DO
    UPDATE Shuttles SET Cycles = 0, Available = TRUE;

CREATE EVENT `end_service_event`
ON SCHEDULE EVERY 1 DAY STARTS TIMESTAMP(CURRENT_DATE, '17:00:00')
DO
    UPDATE Shuttles SET Available = FALSE;

SET time_zone = @OLD_TIME_ZONE;

-- -----------------------------------------------------
-- Data
-- -----------------------------------------------------
START TRANSACTION;

INSERT INTO `Shuttles` (`idShuttles`, `StartTime`) VALUES
  (101, '09:00:00'),
  (102, '09:01:30'),
  (103, '09:03:00'),
  (104, '09:04:30'),
  (105, '09:06:00'),
  (106, '09:07:30'),
  (107, '09:09:00'),
  (108, '09:10:30'),
  (109, '09:12:00'),
  (110, '09:13:30');

INSERT INTO `Stops` (`idStops`, `Name`, `Duration`) VALUES
  (1, 'Retro Cafe', '00:01:30'),
  (2, 'NICE Ground', '00:03:00'),
  (3, 'Concordia 2', '00:04:30'),
  (4, 'Main Office', '00:06:00'),
  (5, 'Girls\' Hostels', '00:07:30'),
  (6, 'Concordia 1', '00:09:00'),
  (7, 'ASAB/SADA', '00:10:30'),
  (8, 'Gate 2', '00:12:00'),
  (9, 'HBL', '00:13:30'),
  (10, 'SMME/SNS', '00:15:00');

-- Every shuttle serves every stop.
INSERT INTO `Info` (`Stops_idStops`, `Shuttles_idShuttles`)
SELECT st.idStops, sh.idShuttles
FROM Stops st
CROSS JOIN Shuttles sh
ORDER BY st.idStops, sh.idShuttles;

COMMIT;
