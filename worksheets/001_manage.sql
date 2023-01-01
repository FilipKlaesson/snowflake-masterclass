// Database to manage stage objects, fileformats etc.
CREATE OR REPLACE DATABASE MANAGE_DB;
CREATE OR REPLACE SCHEMA EXTERNAL_STAGES;
CREATE OR REPLACE SCHEMA FILE_FORMATS;

---- FILE FORMAT ----

-- Creating file format object
CREATE OR REPLACE file format MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT
    SKIP_HEADER = 1;

-- See properties of file format object
DESC file format MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT;

-- Creating file format object for unstructured data
CREATE OR REPLACE file format MANAGE_DB.FILE_FORMATS.JSON_FORMAT
    TYPE = JSON;
    
-- Creating file format object for parquet data
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.PARQUET_FORMAT
    TYPE = 'parquet';
    
---- STAGE ----

-- Creating external stage
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
    url='s3://snowflake-assignments-mc/copyoptions/example1';
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT;

-- Description of external stage
DESC STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE; 

-- List files in stage
LIST @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE; 

-- Creating external stage for unstructured data
CREATE OR REPLACE stage MANAGE_DB.EXTERNAL_STAGES.JSON_STAGE
    url='s3://bucketsnowflake-jsondemo';
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.JSON_FORMAT;

-- List files in stage
LIST @MANAGE_DB.EXTERNAL_STAGES.JSON_STAGE; 

-- Creating external stage for unstructured data
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.PARQUET_STAGE
    url = 's3://snowflakeparquetdemo'   
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.PARQUET_FORMAT;
    
-- List files in stage
LIST @MANAGE_DB.EXTERNAL_STAGES.PARQUET_STAGE;
