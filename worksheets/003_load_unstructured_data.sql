-- Creating raw table with only one variant column
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.JSON_RAW (
    raw variant);
    
-- Load data to raw single-column table
COPY INTO EXERCISE_DB.PUBLIC.JSON_RAW
    FROM @MANAGE_DB.EXTERNAL_STAGES.JSON_STAGE
    
-- Select from a variant field
SELECT 
    RAW:id::INT AS id,  
    RAW:first_name::STRING AS first_name,
    RAW:last_name::STRING AS last_name,
    RAW:gender::STRING AS gender
FROM EXERCISE_DB.PUBLIC.JSON_RAW;

-- Handle nested data
SELECT 
    RAW:first_name::STRING as first_name,
    RAW:job.salary::INT AS salary,
    RAW:job.title::STRING AS title
FROM EXERCISE_DB.PUBLIC.JSON_RAW;

-- Handle arrays

// Get by index
SELECT
    RAW:prev_company[0]::STRING AS prev_company
FROM EXERCISE_DB.PUBLIC.JSON_RAW;

// Get amount
SELECT
    ARRAY_SIZE(RAW:prev_company) AS prev_company
FROM EXERCISE_DB.PUBLIC.JSON_RAW;

// Union
SELECT 
    RAW:id::int AS id,  
    RAW:first_name::STRING AS first_name,
    RAW:prev_company[0]::STRING AS prev_company
FROM EXERCISE_DB.PUBLIC.JSON_RAW
UNION ALL 
SELECT 
    RAW:id::int AS id,  
    RAW:first_name::STRING AS first_name,
    RAW:prev_company[1]::STRING AS prev_company
FROM EXERCISE_DB.PUBLIC.JSON_RAW
ORDER BY id;

// Flatten (make a row for each item in list)
SELECT
    RAW:first_name::STRING AS First_name,
    f.value:language::STRING AS First_language,
    f.value:level::STRING AS Level_spoken
FROM EXERCISE_DB.PUBLIC.JSON_RAW, TABLE(FLATTEN(RAW:spoken_languages)) f;


