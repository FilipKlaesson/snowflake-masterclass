---- SCHEDULING TASKS ----
-- Create a task
CREATE OR REPLACE TASK EXERCISE_DB.PUBLIC.CUSTOMER_INSERT
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'
    WHEN 1=1 // conditioning
    AS INSERT INTO EXERCISE_DB.PUBLIC.CUSTOMERS(CREATE_DATE) VALUES(CURRENT_TIMESTAMP);
    
SHOW TASKS;

-- Starting and suspending tasks
ALTER TASK CUSTOMER_INSERT RESUME;
ALTER TASK CUSTOMER_INSERT SUSPEND;


-- Schedule using CRON
# __________ minute (0-59)
# | ________ hour (0-23)
# | | ______ day of month (1-31, or L)
# | | | ____ month (1-12, JAN-DEC)
# | | | | __ day of week (0-6, SUN-SAT, or L)
# | | | | |
# | | | | |
# * * * * *

CREATE OR REPLACE TASK CUSTOMER_INSERT
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 9,17 * * 5L UTC'
    AS 
    INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(CURRENT_TIMESTAMP);
  
---- TREE OF TASKS ----
-- Suspend parent task
ALTER TASK CUSTOMER_INSERT SUSPEND;
    
-- Create a child task
CREATE OR REPLACE TASK CUSTOMER_INSERT2
    WAREHOUSE = COMPUTE_WH
    AFTER CUSTOMER_INSERT
    AS 
    INSERT INTO CUSTOMERS2 SELECT * FROM CUSTOMERS;

-- Resume tasks (first root task)
ALTER TASK CUSTOMER_INSERT RESUME;
ALTER TASK CUSTOMER_INSERT2 RESUME;

---- STORED PROCEDURES ----
-- Create a stored procedure
CREATE OR REPLACE PROCEDURE CUSTOMERS_INSERT_PROCEDURE (CREATE_DATE varchar)
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    AS
        $$
        var sql_command = 'INSERT INTO EXERCISE_DB.PUBLIC.CUSTOMERS(CREATE_DATE) VALUES(:1);'
        snowflake.execute(
            {
                sqlText: sql_command,
                binds: [CREATE_DATE]
            }
        );
        return "Successfully executed.";
        $$;
        
        
-- Create task
CREATE OR REPLACE TASK CUSTOMER_TAKS_PROCEDURE
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'
    AS CALL CUSTOMERS_INSERT_PROCEDURE (CURRENT_TIMESTAMP);


ALTER TASK CUSTOMER_TAKS_PROCEDURE RESUME;

---- TASK HISTORY ----
-- Get tasks history
SELECT * FROM TABLE(EXERCISE_DB.INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY scheduled_time DESC;
  
-- See results for a specific task in a given time
SELECT * FROM TABLE(EXERCISE_DB.INFORMATION_SCHEMA.TASK_HISTORY(
    scheduled_time_range_start=>dateadd('hour',-4,current_timestamp()),
    result_limit=>5,
    task_name=>'CUSTOMER_INSERT2'));
 
-- See results for a given time period
SELECT * FROM TABLE(EXERCISE_DB.INFORMATION_SCHEMA.TASK_HISTORY(
    scheduled_time_range_start=>to_timestamp_ltz('2021-04-22 11:28:32.776 -0700'),
    scheduled_time_range_end=>to_timestamp_ltz('2021-04-22 11:35:32.776 -0700')));  
