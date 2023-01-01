---- MATERIALIZED VIEWS ----
-- Create materialized view
CREATE OR REPLACE MATERIALIZED VIEW EXERCISE_DB.PUBLIB.ORDERS_MV
AS SELECT
    YEAR(O_ORDERDATE) AS YEAR,
    MAX(O_COMMENT) AS MAX_COMMENT,
    MIN(O_COMMENT) AS MIN_COMMENT,
    MAX(O_CLERK) AS MAX_CLERK,
    MIN(O_CLERK) AS MIN_CLERK
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS
GROUP BY YEAR(O_ORDERDATE);

-- Cost of materialized views
SELECT * FROM TABLE(EXERCISE_DB.INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTROY());
