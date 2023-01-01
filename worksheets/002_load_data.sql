-- Creating table
CREATE OR REPLACE DATABASE EXERCISE_DB;
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.EMPLOYEES (
    customer_id int,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(50),
    age int,
    city varchar(50));

---- LOAD DATA ----

-- Use validation mode to check load status
COPY INTO EXERCISE_DB.PUBLIC.EMPLOYEES
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
        VALIDATION_MODE = RETURN_ERRORS; 

-- Use ON_ERROR to handle errors
COPY INTO EXERCISE_DB.PUBLIC.EMPLOYEES
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
      ON_ERROR = CONTINUE;      
  
---- LOAD TRANSFORM DATA ----
    
COPY INTO EXERCISE_DB.PUBLIC.EMPLOYEES
    FROM (
        SELECT
            s.$1,
            s.$2, 
            s.$3,
            CONCAT(s.$2, '.', s.$3, '@mycompany.com'),
            s.$5,
            s.$6
        FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE s
    )
    ON_ERROR = CONTINUE;      
    
SELECT * FROM EXERCISE_DB.PUBLIC.EMPLOYEES;
