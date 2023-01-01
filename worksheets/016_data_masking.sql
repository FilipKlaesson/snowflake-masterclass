---- DATA MASKING ----
-- Set up masking policy
CREATE OR REPLACE MASKING POLICY phone 
    AS (val varchar) RETURNS varchar ->
        CASE        
        WHEN current_role() IN ('ANALYST_FULL', 'ACCOUNTADMIN') THEN val
        ELSE '##-###-##'
        END;
  
-- Apply policy on a specific column 
ALTER TABLE IF EXISTS EXERCISE_DB.PUBLIC.CUSTOMERS MODIFY COLUMN phone 
SET MASKING POLICY PHONE;

-- Show columns with applied policy
SELECT * FROM table(information_schema.policy_references(policy_name=>'phone'));

-- Remove policy before replacing/dropping 
ALTER TABLE IF EXISTS EXERCISE_DB.PUBLIC.CUSTOMERS MODIFY COLUMN phone
UNSET MASKING POLICY;

-- Alter existing policy 
ALTER MASKING POLICY phone SET BODY ->
    CASE        
    WHEN current_role() in ('ANALYST_FULL', 'ACCOUNTADMIN') THEN val
    ELSE '**-**-**'
    END;
