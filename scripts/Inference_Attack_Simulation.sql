/*
==============================================================
Title: Inference Attack Simulation - Week 4
Author: [HOSSAM]
Database: Assiment_week4_test2
Description:
This script demonstrates how inference attacks can occur when
data is split into separate views, and how to mitigate them
by controlling access privileges.
==============================================================
*/

USE Assiment_week4_test2;
GO

 --   part 3
--==============================================================
-- 1. CREATE PUBLIC VIEWS FOR SIMULATION
--==============================================================
CREATE VIEW dbo.vPublicNamesS AS
SELECT TOP 100 PERCENT FullName
FROM dbo.Employees
ORDER BY EmpID;
GO

CREATE VIEW dbo.vPublicSalaries AS
SELECT TOP 100 PERCENT Salary
FROM dbo.Employees
ORDER BY EmpID;
GO

--==============================================================
-- 2. GRANT SELECT PRIVILEGES TO PUBLIC
--==============================================================
GRANT SELECT ON dbo.vPublicNamesS TO PUBLIC;
GRANT SELECT ON dbo.vPublicSalaries TO PUBLIC;
GO

--==============================================================
-- 3. TEST ACCESS AS general_user (Before Restriction)
--==============================================================
EXECUTE AS USER = 'general_user';
SELECT * FROM dbo.vPublicNamesS;    -- ACCEPT
SELECT * FROM dbo.vPublicSalaries;  -- ACCEPT
REVERT;
GO

--==============================================================
-- 4. SIMULATE SECURITY FIX BY REVOKING SENSITIVE VIEW ACCESS
--==============================================================
REVOKE SELECT ON dbo.vPublicSalaries TO PUBLIC;
GO

EXECUTE AS USER = 'general_user';
SELECT * FROM dbo.vPublicNamesS;    --ACCEPT
SELECT * FROM dbo.vPublicSalaries;  --DENY
REVERT;
GO

--==============================================================
-- 5. CHECK CURRENT SECURITY CONTEXT & OBJECTS
--==============================================================
SELECT 
    SUSER_NAME() AS LoginName,
    USER_NAME() AS DatabaseUserName;
GO

SELECT name, type_desc 
FROM sys.objects 
WHERE name IN ('vPublicNames', 'vAnonymizedData', 'vAttackView', 'vPublicNamesS', 'vPublicSalaries');
GO

-- End of Script
