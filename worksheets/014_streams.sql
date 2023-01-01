---- STREAMS ----
-- Create a stream object
CREATE OR REPLACE STREAM CUSTOMER_STREAM 
ON TABLE EXERCISE_DB.PUBLIC.CUSTOMER
APPEND_ONLY = FALSE;

SHOW STREAMS;
DESC STREAM CUSTOMER_STREAM;

-- Consume stream object (inserts)
INSERT INTO EXERCISE_DB.PUBLIC.CUSTOMER2 
SELECT * FROM CUSTOMER_STREAM;
        
-- Consume stream object (updates (1 update = 1 delete + 1 insert))
MERGE INTO EXERCISE_DB.PUBLIC.CUSTOMER2 C2
USING CUSTOMER_STREAM CS ON C2.id = CS.id                 
WHEN MATCHED 
AND S.METADATA$ACTION ='INSERT'
AND S.METADATA$ISUPDATE ='TRUE' -- Indicates the record has been updated 
THEN UPDATE 
SET C2.fist_name = CS.fist_name,
    C2.last_name = CS.last_name;

-- Consume stream object (deletes)
MERGE INTO EXERCISE_DB.PUBLIC.CUSTOMER2 C2
USING CUSTOMER_STREAM CS ON C2.id = CS.id 
WHEN MATCHED
    AND S.METADATA$ACTION ='DELETE'
    AND S.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE;
    
-- Consume stream object (all changes)
MERGE INTO EXERCISE_DB.PUBLIC.CUSTOMER2 C2
USING CUSTOMER_STREAM CS ON C2.id=CS.id
WHEN MATCHED
    AND CS.METADATA$ACTION ='DELETE'
    AND CS.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE
WHEN MATCHED
    AND CS.METADATA$ACTION ='INSERT' 
    AND CS.METADATA$ISUPDATE = 'TRUE'       
    THEN UPDATE
    SET C2.first_name = CS.first_name,
        C2.last_name = CS.last_name
WHEN NOT MATCHED 
    AND CS.METADATA$ACTION ='INSERT'
    THEN INSERT (first_name, last_name)
    VALUES (CS.first_name, CS.last_name)
    
---- AUTOMATE CONSUMPTION USING TASKS ----
-- Create task
CREATE OR REPLACE TASK ALL_DATA_CHANGES
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('CUSTOMER_STREAM')
    AS 
MERGE INTO EXERCISE_DB.PUBLIC.CUSTOMER2 C2
USING CUSTOMER_STREAM CS ON C2.id=CS.id
WHEN MATCHED
    AND CS.METADATA$ACTION ='DELETE'
    AND CS.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE
WHEN MATCHED
    AND CS.METADATA$ACTION ='INSERT' 
    AND CS.METADATA$ISUPDATE = 'TRUE'       
    THEN UPDATE
    SET C2.first_name = CS.first_name,
        C2.last_name = CS.last_name
WHEN NOT MATCHED 
    AND CS.METADATA$ACTION ='INSERT'
    THEN INSERT (first_name, last_name)
    VALUES (CS.first_name, CS.last_name)

ALTER TASK ALL_DATA_CHANGES RESUME;

---- USE CHANGE-CLAUSE INSTEAD OF STREAM TO TRACK CHANGES ----
-- Set change tracking
ALTER TABLE EXERCISE_DB.PUBLIC.EMPLOYEES
SET CHANGE_TRACKING = TRUE;

-- Get changes by time travel 
SELECT * FROM EXERCISE_DB.PUBLIC.EMPLOYEES
CHANGES(information => default)
// CHANGES(information => append_only)
AT (offset => -0.5*60);

SELECT * FROM EXERCISE_DB.PUBLIC.EMPLOYEES
CHANGES(information  => default)
AT (timestamp => 'your-timestamp'::timestamp_tz);
