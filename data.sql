-- start time of every single shuttle will be rthe same
-- we will take the start time of a single shuttle and subtract it with the stop time 
--  we will calcylate the total time taken by multiplying the no of cycles by stop time aand them subtract it.
-- when no of cycles reach time for 5 pm the no of cycles will reset
-- for triggers, after the last stop, a trigger will active that will increase the no of cycles by 1
-- another trigger will be for resrtting the no of cycles on 5 pm
-- there will be two types of users student and drivers the student view will only be able tto select and driver will be able to select and update
-- driver can select the whole table while only update the available attribute

INSERT INTO shuttles VALUES (01, 90000, 1);
INSERT INTO shuttles VALUES (02, 90130, 1);
INSERT INTO shuttles VALUES (03, 90300, 1);
INSERT INTO shuttles VALUES (04, 90430, 1);
INSERT INTO shuttles VALUES (05, 90600, 1);
INSERT INTO shuttles VALUES (06, 90730, 1);
INSERT INTO shuttles VALUES (07, 90900, 1);
INSERT INTO shuttles VALUES (08, 91030, 1);
INSERT INTO shuttles VALUES (09, 91200, 1);
INSERT INTO shuttles VALUES (10, 91330, 1);

