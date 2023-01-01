---- CLONING TABLES----
CREATE TABLE EXERCISE_DB.PUBLIC.CUSTOMERS_CLONE
CLONE EXERCISE_DB.PUBLIC.CUSTOMERS

-- Update cloned table (does not update original table)
UPDATE EXERCISE_DB.PUBLIC.CUSTOMERS_CLONE SET LAST_NAME = NULL

---- CLONING SCHEMAS ----
CREATE TRANSIENT SCHEMA EXERCISE_DB.COPIED_SCHEMA
CLONE EXERCISE_DB.PUBLIC;

---- CLONING DATABASES ----
CREATE TRANSIENT DATABASE EXERCISE_DB_COPY
CLONE EXERCISE_DB;

---- CLONING USING TIME TRAVEL ----
-- Using at offset
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.TIME_TRAVEL_CLONE
CLONE EXERCISE_DB.PUBLIC.TIME_TRAVEL at (OFFSET => -60*1.5);

// Using before statement 
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.TIME_TRAVEL_CLONE
CLONE EXERCISE_DB.PUBLIC.TIME_TRAVEL before (statement => '<your-query-id>');

---- SWAPPING TABLES ----
ALTER TABLE EXERCISE_DB.PUBLIC.CUSTOMERS_CLONE SWAP WITH EXERCISE_DB.PUBLIC.CUSTOMERS;
