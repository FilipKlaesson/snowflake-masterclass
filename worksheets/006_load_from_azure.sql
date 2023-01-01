---- CREATE INTEGRATION OBJECT ----

-- create integration object that contains the access information
CREATE OR REPLACE STORAGE INTEGRATION azure_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE
  AZURE_TENANT_ID = '<your-azure-tenant-id>'
  STORAGE_ALLOWED_LOCATIONS = ('azure://your-account.blob.core.windows.net/your-container/path/data');

-- Describe integration object to provide access
DESC STORAGE integration azure_integration;

---- CREATE FILE FORMAT AND STAGE OBJECT ----

-- Create file format object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.AZURE_FILE_FORMAT
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1;

-- Create stage object with integration object & file format object
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.stage_azure
    STORAGE_INTEGRATION = azure_integration
    URL = 'azure://your-account.blob.core.windows.net/your-container/path/data'
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.AZURE_FILE_FORMAT;

LIST @MANAGE_DB.EXTERNAL_STAGES.stage_azure;

---- LOAD DATA ----

SELECT 
$1,
$2,
$3,
$4,
$5,
$6,
$7,
$8,
$9,
$10,
$11,
$12,
$13,
$14,
$15,
$16,
$17,
$18,
$19,
$20
FROM @MANAGE_DB.EXTERNAL_STAGES.stage_azure;


CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.HAPPINESS (
    country_name varchar,
    regional_indicator varchar,
    ladder_score number(4,3),
    standard_error number(4,3),
    upperwhisker number(4,3),
    lowerwhisker number(4,3),
    logged_gdp number(5,3),
    social_support number(4,3),
    healthy_life_expectancy number(5,3),
    freedom_to_make_life_choices number(4,3),
    generosity number(4,3),
    perceptions_of_corruption number(4,3),
    ladder_score_in_dystopia number(4,3),
    explained_by_log_gpd_per_capita number(4,3),
    explained_by_social_support number(4,3),
    explained_by_healthy_life_expectancy number(4,3),
    explained_by_freedom_to_make_life_choices number(4,3),
    explained_by_generosity number(4,3),
    explained_by_perceptions_of_corruption number(4,3),
    dystopia_residual number (4,3));
    
    
COPY INTO EXERCISE_DB.PUBLIC.HAPPINESS
FROM @MANAGE_DB.EXTERNAL_STAGES.stage_azure;

---- LOAD UNSTRUCTURED DATA ----

-- Create file format for json 
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.AZURE_JSON_FILE_FORMAT
    TYPE = JSON;
 
-- Create stage
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.stage_azure
    STORAGE_INTEGRATION = azure_integration
    URL = 'azure://your-account.blob.core.windows.net/your-container/path/data'
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.AZURE_FILE_FORMAT; 
  
LIST  @MANAGE_DB.EXTERNAL_STAGES.stage_azure;
  
-- Create table
CREATE OR REPLACE TABLE car_owner (
    car_model varchar, 
    car_model_year int,
    car_make varchar, 
    first_name varchar,
    last_name varchar)
 
-- Copy data into table
COPY INTO car_owner
FROM(
    SELECT 
        $1:"Car Model"::STRING as car_model, 
        $1:"Car Model Year"::INT as car_model_year,
        $1:"car make"::STRING as "car make", 
        $1:"first_name"::STRING as first_name,
        $1:"last_name"::STRING as last_name
    FROM @MANAGE_DB.EXTERNAL_STAGES.stage_azure
);

-- Alternative: Using a raw file table step
CREATE OR REPLACE TABLE car_owner_raw (
  raw variant);

COPY INTO car_owner_raw
FROM @MANAGE_DB.EXTERNAL_STAGES.stage_azure;

INSERT INTO car_owner(
    SELECT 
        $1:"Car Model"::STRING as car_model, 
        $1:"Car Model Year"::INT as car_model_year,
        $1:"car make"::STRING as car_make, 
        $1:"first_name"::STRING as first_name,
        $1:"last_name"::STRING as last_name
    FROM car_owner_raw
)    
