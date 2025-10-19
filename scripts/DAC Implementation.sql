/*
==============================================================
Title: DAC Implementation Assignment - Week 4
Author: [HOSSAM]
Database: Assiment_week4_test2
Description:
This script demonstrates SQL Server DAC (Discretionary Access Control)
implementation using roles, users, and privilege management.
==============================================================
*/

--==============================================================
-- 1. CREATE DATABASE AND USE IT
--==============================================================
CREATE DATABASE Assiment_week4_test2;
GO

USE Assiment_week4_test2;
GO

--==============================================================
-- 2. CREATE TABLE
--==============================================================
CREATE TABLE dbo.Employees (
    EmpID INT PRIMARY KEY,
    FullName NVARCHAR(20) NOT NULL,
    Salary MONEY  -- Sensitive data
);
GO

--==============================================================
-- 3. INSERT SAMPLE DATA
--==============================================================
INSERT INTO dbo.Employees VALUES
(1, 'Ali', 120000),
(2, 'Asser', 110000),
(3, 'Mona', 100000),
(4, 'Fatma', 90000),
(5, 'Gehad', 80000),
(6, 'Ahmed', 70000);
GO

--==============================================================
-- 4. DAC IMPLEMENTATION: LOGINS & USERS
--==============================================================
CREATE LOGIN user_public WITH PASSWORD = '123456';
CREATE LOGIN user_admin  WITH PASSWORD = '123456';
GO

CREATE USER general_user FOR LOGIN user_public;
CREATE USER admin1 FOR LOGIN user_admin;
GO

--==============================================================
-- 5. CREATE ROLES
--==============================================================
CREATE ROLE public_role;
CREATE ROLE admin_role;
GO

--==============================================================
-- 6. ASSIGN PRIVILEGES TO ROLES
--==============================================================
GRANT SELECT, UPDATE, DELETE, INSERT ON dbo.Employees TO admin_role;
GRANT SELECT ON dbo.Employees TO public_role;
GO

--==============================================================
-- 7. ASSIGN USERS TO ROLES
--==============================================================
ALTER ROLE public_role ADD MEMBER general_user;
ALTER ROLE admin_role ADD MEMBER admin1;
GO

--==============================================================
-- 8. TEST PRIVILEGES WITH EXECUTE AS
--==============================================================

-- Test 1: general_user
EXECUTE AS USER = 'general_user';
SELECT * FROM dbo.Employees; --ACCEPT
INSERT INTO dbo.Employees VALUES (7, 'Gehad', 80000), (8, 'Ahmed', 70000); --DENY
DELETE FROM dbo.Employees WHERE EmpID = 8; --  DENY
UPDATE dbo.Employees SET FullName = 'HOSSAM' WHERE EmpID = 1; --DENY
REVERT;
GO

-- Test 2: admin1
EXECUTE AS USER = 'admin1';
SELECT * FROM dbo.Employees; --  ACCEPT
INSERT INTO dbo.Employees VALUES (7, 'Gehad', 80000), (8, 'Ahmed', 70000); --  ACCEPT
DELETE FROM dbo.Employees WHERE EmpID = 7; --  ACCEPT
UPDATE dbo.Employees SET FullName = 'HOSSAM' WHERE EmpID = 1; --  ACCEPT
REVERT;
GO

--==============================================================
-- 9. ANONYMIZATION & VIEW-BASED ACCESS CONTROL
--==============================================================

-- Create anonymized view for public users
CREATE VIEW dbo.vAnonymizedData AS
SELECT EmpID, FullName, 'Confidential' AS Salary
FROM dbo.Employees;
GO

-- Create public names view
CREATE VIEW dbo.vPublicNames AS
SELECT EmpID, FullName
FROM dbo.Employees;
GO

-- Revoke direct access to Employees for public_role
REVOKE SELECT ON dbo.Employees TO public_role;
GO

-- Grant access to anonymized and public views
GRANT SELECT ON dbo.vAnonymizedData TO public_role;
GRANT SELECT ON dbo.vPublicNames TO PUBLIC;
GO

-- Allow general_user to create and modify views in dbo schema
GRANT CREATE VIEW TO general_user;
ALTER USER general_user WITH DEFAULT_SCHEMA = dbo;
GRANT ALTER ON SCHEMA::dbo TO general_user;
GO

--==============================================================
-- 10. TEST VIEW ACCESS AS general_user
--==============================================================
EXECUTE AS USER = 'general_user';
SELECT * FROM dbo.vPublicNames;       -- ACCEPT
SELECT * FROM dbo.vAnonymizedData;    -- ACCEPT

-- Attempt to create a malicious join view
CREATE VIEW dbo.vAttackView AS
SELECT a.EmpID, a.FullName, b.Salary
FROM dbo.vPublicNames a
JOIN dbo.vAnonymizedData b ON a.EmpID = b.EmpID;
GO
REVERT

-- Grant SELECT permission on the new view
GRANT SELECT ON dbo.vAttackView TO general_user;
GO

EXECUTE AS USER = 'general_user';
-- Test reading from the attack view
SELECT * FROM dbo.vAttackView;  -- May expose sensitive data
REVERT;
GO

--==============================================================
-- 11. CLEANUP / SECURITY ADJUSTMENTS
--==============================================================
REVOKE SELECT ON dbo.vPublicNames TO PUBLIC;
GO

--==============================================================
-- 12. CHECK OBJECTS & SECURITY CONTEXT
--==============================================================
SELECT 
    SUSER_NAME() AS LoginName,
    USER_NAME() AS DatabaseUserName;
GO

SELECT name, type_desc 
FROM sys.objects 
WHERE name IN ('vPublicNames', 'vAnonymizedData', 'vAttackView');
GO
