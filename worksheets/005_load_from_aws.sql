---- CREATE STORAGE INTEGRATION ----

-- Create storage integration object
CREATE OR REPLACE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = ''
  STORAGE_ALLOWED_LOCATIONS = ('s3://<your-bucket-name>/<your-path>/', 's3://<your-bucket-name>/<your-path>/')
   COMMENT = 'This an optional comment' 
   
   
-- See storage integration properties to fetch external_id so we can update it in S3
DESC integration s3_int;

---- CREATE FILE FORMAT AND STAGE OBJECT ----

-- Create file format object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILE_FORMAT
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE    
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
    
-- Create stage object with integration object & file format object
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.CSV_BUCKET
    URL = 's3://<your-bucket-name>/<your-path>/'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.CSV_FILE_FORMAT

---- LOAD DATA ----

-- Create table
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.MOVIE_TITLES (
  show_id STRING,
  type STRING,
  title STRING,
  director STRING,
  cast STRING,
  country STRING,
  date_added STRING,
  release_year STRING,
  rating STRING,
  duration STRING,
  listed_in STRING,
  description STRING )
  
-- Use Copy command       
COPY INTO EXERCISE_DB.PUBLIC.MOVIE_TITLES
    FROM @MANAGE_DB.EXTERNAL_STAGES.CSV_BUCKET
    
---- LOAD UNSTRUCTURED DATA ---- 

SELECT * FROM @MANAGE_DB.EXTERNAL_STAGES.JSON_BUCKET

-- Create table
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.REVIEWS (
    asin STRING,
    helpful STRING,
    overall STRING,
    reviewtext STRING,
    reviewtime DATE,
    reviewerid STRING,
    reviewername STRING,
    summary STRING,
    unixreviewtime DATE
)

-- Copy transformed data into destination table
COPY INTO EXERCISE_DB.PUBLIC.REVIEWS
    FROM (
        SELECT 
            $1:asin::STRING as ASIN,
            $1:helpful as helpful,
            $1:overall as overall,
            $1:reviewText::STRING as reviewtext,
            DATE_FROM_PARTS( 
              RIGHT($1:reviewTime::STRING,4), 
              LEFT($1:reviewTime::STRING,2), 
              CASE WHEN SUBSTRING($1:reviewTime::STRING,5,1)=',' 
                    THEN SUBSTRING($1:reviewTime::STRING,4,1) ELSE SUBSTRING($1:reviewTime::STRING,4,2) END),
            $1:reviewerID::STRING,
            $1:reviewerName::STRING,
            $1:summary::STRING,
            DATE($1:unixReviewTime::int) Revewtime
        FROM @MANAGE_DB.EXTERNAL_STAGES.JSON_BUCKET
    ); 
