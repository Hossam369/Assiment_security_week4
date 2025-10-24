
USE Assiment_week4_test2;
GO

/* ============================================================
   PART 4 — INFERENCE ATTACK PREVENTION LAB
   Author: Hossam Nady
   Description:
   This script demonstrates how to prevent inference attacks
   by using PublicIDs, restricted roles, and view permissions.
   ============================================================ */

/* ============================================================
   1. ADD COLUMN => GENERATE PUBLIC ID IN Employees TABLE
   ============================================================ */

-- Step 1: Add a new column named PublicID (temporarily allowing NULLs)
ALTER TABLE dbo.Employees
ADD PublicID UNIQUEIDENTIFIER NULL;
GO

-- Step 2: Assign each existing record a unique NEWID()
UPDATE dbo.Employees
SET PublicID = NEWID()
WHERE PublicID IS NULL;
GO

-- Step 3: Make PublicID NOT NULL
ALTER TABLE dbo.Employees
ALTER COLUMN PublicID UNIQUEIDENTIFIER NOT NULL;
GO

-- Step 4: Add a default constraint to auto-generate a new ID for future inserts
ALTER TABLE dbo.Employees
ADD CONSTRAINT DF_Employees_PublicID DEFAULT NEWID() FOR PublicID;
GO


/* ============================================================
   2. CREATE AdminMap TABLE — LINK PublicID WITH EmpID
   ============================================================ */

CREATE TABLE dbo.AdminMap (
    PublicID UNIQUEIDENTIFIER,
    EmpID INT,
    PRIMARY KEY (PublicID)
);
GO

-- Insert existing mapping data
INSERT INTO dbo.AdminMap (PublicID, EmpID)
SELECT PublicID, EmpID FROM dbo.Employees;
GO

-- Grant and deny permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.AdminMap TO admin_role;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.AdminMap TO public_role;
GO

-- Prevent the public_role from creating views
DENY CREATE VIEW TO public_role;
GO


/* ============================================================
   3. SIMULATE INFERENCE ATTACK SCENARIO
   ============================================================ */

-- Step 1: Create public views that expose limited info
CREATE VIEW dbo.vPublicNames_two AS
SELECT TOP 100 PERCENT PublicID, FullName
FROM dbo.Employees
ORDER BY NEWID(); -- Random order
GO

CREATE VIEW dbo.vPublicSalaries_two AS
SELECT TOP 100 PERCENT PublicID, Salary
FROM dbo.Employees
ORDER BY NEWID(); -- Random order
GO

-- Grant access to public users
GRANT SELECT ON dbo.vPublicNames_two TO PUBLIC;
GRANT SELECT ON dbo.vPublicSalaries_two TO PUBLIC;
GO


/* ============================================================
   4. ATTACK SIMULATION (EXPECTED TO FAIL)
   ============================================================ */

-- Attempt to create a combined view as general_user
EXECUTE AS USER = 'general_user';
GO

-- This should fail because public_role is denied CREATE VIEW permission
CREATE VIEW dbo.vAttackView_two AS
SELECT a.FullName, b.Salary
FROM dbo.vPublicNames a
JOIN dbo.vPublicSalaries b ON a.PublicID = b.PublicID;
GO

-- Try to read from the attack view (it shouldn't exist)
SELECT * FROM dbo.vAttackView_two;
GO

-- Revert to the original user
REVERT;
GO

/* ============================================================
   END OF SCRIPT
   ============================================================ */
