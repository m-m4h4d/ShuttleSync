-- Optional: a restricted account for shuttle drivers that can only update
-- the Shuttles table (e.g. to mark a shuttle unavailable).
--
-- Pick a strong password, replace CHANGE_ME below, and run it once as an
-- admin after schema.sql. Do not commit the real password.

DROP USER IF EXISTS 'driver';
CREATE USER 'driver' IDENTIFIED BY 'CHANGE_ME';
GRANT SELECT, UPDATE ON `ShuttleSync`.`Shuttles` TO 'driver';
