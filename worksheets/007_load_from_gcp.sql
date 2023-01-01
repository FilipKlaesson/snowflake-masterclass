---- CREATE INTEGRATION OBJECT ----

-- Create integration object that contains the access information
CREATE OR REPLACE STORAGE INTEGRATION gcp_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = GCS
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://bucket/path', 'gcs://bucket/path2');
  
-- Describe integration object to provide access
DESC STORAGE INTEGRATION gcp_integration;

---- CREATE FILE FORMAT AND STAGE ----

-- Create file format
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.GCP_FILE_FORMAT
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1;

-- create stage object
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.stage_gcp
    STORAGE_INTEGRATION = gcp_integration
    URL = 'gcs://bucket/path'
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.GCP_FILE_FORMAT;

LIST @MANAGE_DB.EXTERNAL_STAGES.stage_gcp;

---- LOAD DATA ----
SELECT 
    $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,
    $12,$13,$14,$15,$16,$17,$18,$19,$20
FROM @MANAGE_DB.EXTERNAL_STAGES.stage_gcp;

CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.HAPPINESS(
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
FROM @MANAGE_DB.EXTERNAL_STAGES.stage_gcp;

---- UNLOAD DATA ----

-- Create stage object
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.stage_gcp
    STORAGE_INTEGRATION = gcp_integration
    URL = 'gcs://bucket/new_path'
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.GCP_FILE_FORMAT
    --compression = gzip | auto
    ;

-- Unload data
COPY INTO @stage_gcp
FROM EXERCISE_DB.PUBLIC.HAPPINESS;
