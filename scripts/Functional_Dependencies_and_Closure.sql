/*
==============================================================
Title: Part 5 — Functional Dependencies (FDs) & Attribute Closure
Author: [Your Name]
Database: Assiment_week4_test2
Description:
This script demonstrates:
- Adding dependent attributes (Dept, Title, Grade, Bonus)
- Defining functional dependencies (FDs)
- Populating the Employees table with consistent sample data
- Performing a closure example manually:
    FD₁: EmpID → Dept
    FD₂: Title → Grade
    FD₃: Dept, Grade → Bonus
==============================================================
*/

USE Assiment_week4_test2;
GO

--==============================================================
-- 1. Add new columns to Employees table
--==============================================================
IF COL_LENGTH('dbo.Employees', 'Dept') IS NULL
BEGIN
    ALTER TABLE dbo.Employees 
    ADD Dept NVARCHAR(20), Title NVARCHAR(20), Grade NVARCHAR(10), Bonus MONEY;
END;
GO

--==============================================================
-- 2. Insert or update data to follow the defined FDs
--     FDs:
--     (1) EmpID → Dept
--     (2) Title → Grade
--     (3) Dept, Grade → Bonus
--==============================================================
UPDATE dbo.Employees
SET 
    Dept = CASE EmpID 
        WHEN 1 THEN 'IT' 
        WHEN 2 THEN 'HR' 
        WHEN 3 THEN 'IT'
        WHEN 4 THEN 'Finance' 
        WHEN 5 THEN 'HR' 
        WHEN 6 THEN 'Finance' 
        ELSE Dept
    END,
    Title = CASE EmpID 
        WHEN 1 THEN 'Manager' 
        WHEN 2 THEN 'Senior' 
        WHEN 3 THEN 'Developer'
        WHEN 4 THEN 'Analyst' 
        WHEN 5 THEN 'Assistant' 
        WHEN 6 THEN 'Junior' 
        ELSE Title
    END,
    Grade = CASE Title 
        WHEN 'Manager' THEN 'A' 
        WHEN 'Senior' THEN 'B' 
        WHEN 'Developer' THEN 'C' 
        WHEN 'Analyst' THEN 'C' 
        WHEN 'Assistant' THEN 'D' 
        WHEN 'Junior' THEN 'D' 
        ELSE Grade
    END,
    Bonus = CASE 
        WHEN Dept = 'IT' AND Grade = 'A' THEN 15000 
        WHEN Dept = 'HR' AND Grade = 'B' THEN 12000 
        WHEN Dept = 'IT' AND Grade = 'C' THEN 10000 
        WHEN Dept = 'Finance' AND Grade = 'C' THEN 9000 
        WHEN Dept = 'HR' AND Grade = 'D' THEN 6000 
        WHEN Dept = 'Finance' AND Grade = 'D' THEN 5000 
        ELSE Bonus
    END;
GO

--==============================================================
-- 3. Display data to verify consistency with FDs
--==============================================================
SELECT 
    EmpID, FullName, Dept, Title, Grade, Bonus
FROM dbo.Employees
ORDER BY EmpID;
GO

--==============================================================
-- 4. Manual Closure Demonstration (for explanation)
--==============================================================
-- Step-by-step derivation:
--   Q⁰ = {Dept, Title}
--   Apply FD₂: Title → Grade → Q¹ = {Dept, Title, Grade}
--   Apply FD₃: Dept, Grade → Bonus → Q² = {Dept, Title, Grade, Bonus}
--   Therefore: Q⁺ = {Dept, Title, Grade, Bonus}
--   Proof: Bonus ∈ Q⁺ ✓
--==============================================================

-- End of Script

