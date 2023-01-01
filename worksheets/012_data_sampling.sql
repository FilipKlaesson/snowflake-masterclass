---- DATA SAMPLING ----
-- Sample row/Bernoulli
CREATE OR REPLACE VIEW ADDRESS_SAMPLE AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS 
SAMPLE ROW (1) SEED(23);

-- Sample block/system
CREATE OR REPLACE VIEW ADDRESS_SAMPLE AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS 
SAMPLE SYSTEM (1) SEED(23);