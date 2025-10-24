USE Assiment_week4_test2;
GO

-- ==========================================================
-- Part 6 — Inference Attack Prevention
-- ==========================================================

-- 1️⃣ Create a new view that hides direct salary info
--    Instead of showing raw salary data, we show salary ranges
CREATE VIEW dbo.vAnonymizedData
AS
SELECT 
    EmpID,
    FullName,
    CASE 
        WHEN Salary < 5000 THEN 'Low'
        WHEN Salary BETWEEN 5000 AND 10000 THEN 'Medium'
        WHEN Salary BETWEEN 10001 AND 15000 THEN 'High'
        ELSE 'Very High'
    END AS SalaryRange
FROM dbo.Employees;
GO

-- 2️⃣ Grant limited access to general users (safe data only)
GRANT SELECT ON dbo.vAnonymizedData TO PUBLIC;
GO

-- 3️⃣ Simulate general user access (inference-safe)
EXECUTE AS USER = 'general_user';
SELECT * FROM dbo.vAnonymizedData;  -- Allowed: anonymized salary info only
REVERT;
GO

-- 4️⃣ Try to access sensitive views (should be denied)
EXECUTE AS USER = 'general_user';
SELECT * FROM dbo.vPublicSalaries;  -- DENY expected
REVERT;
GO

-- 5️⃣ Verify which objects exist in DB
SELECT name, type_desc 
FROM sys.objects 
WHERE name LIKE 'v%';
GO

-- 6️⃣ Show current user context
SELECT 
    SUSER_NAME() AS LoginName,
    USER_NAME() AS DatabaseUserName;
GO

