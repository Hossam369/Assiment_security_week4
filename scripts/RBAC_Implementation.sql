
USE Assiment_week4_test2
GO 

--Part 2 — RBAC Implementation
--1-CREATE read_onlyX & insert_onlyX
CREATE ROLE read_onlyX ;
CREATE ROLE insert_onlyX;
GO 

--2-GRANT SELECT TO read_onlyX  & INSERT TO insert_onlyX
GRANT SELECT ON dbo.Employees TO read_onlyX;
GO
GRANT INSERT ON dbo.Employees TO insert_onlyX;
GO

--3-CREATE LOGIN AND USERS THEN ASSIGN ROLES  
CREATE LOGIN read_user WITH PASSWORD = 'read123';
CREATE LOGIN insert_user WITH PASSWORD = 'insert123';

CREATE USER read_user FOR LOGIN read_user;
CREATE USER insert_user FOR LOGIN insert_user;

ALTER ROLE read_onlyX ADD MEMBER read_user;
ALTER ROLE insert_onlyX ADD MEMBER insert_user;

--4-
-- Test read_user
EXECUTE AS USER = 'read_user';
SELECT * FROM dbo.Employees; -- ACCEPT
INSERT INTO dbo.Employees VALUES (7, 'Sara', 60000); -- DENY
REVERT;

-- Test insert_user
EXECUTE AS USER = 'insert_user';
SELECT * FROM dbo.Employees; -- DENY
INSERT INTO dbo.Employees VALUES (8, 'Sara', 60000); -- ACCEPT
REVERT;

--5-power_user Inherit from read_onlyX & insert_onlyX
CREATE ROLE power_user;
GO
ALTER ROLE power_user ADD MEMBER read_onlyX;
GO
ALTER ROLE power_user ADD MEMBER insert_onlyX;
GO

--6-Assign user to power role 
CREATE LOGIN power_user_acc WITH PASSWORD = 'power123';
CREATE USER power_user_acc FOR LOGIN power_user_acc;
ALTER ROLE power_user ADD MEMBER power_user_acc;

--7- Test power_user_acc before REVOKE
EXECUTE AS USER = 'power_user_acc';
SELECT * FROM dbo.Employees; -- ACCEPT
INSERT INTO dbo.Employees VALUES (8, 'Tarek', 65000); -- ACCEPT
REVERT;

--8- REVOKE one role (e.g., insert_onlyX)
REVOKE INSERT ON dbo.Employees FROM insert_onlyX;
GO

--9- Test power_user_acc after REVOKE
EXECUTE AS USER = 'power_user_acc';
SELECT * FROM dbo.Employees; -- ACCEPT (from read_onlyX)
INSERT INTO dbo.Employees VALUES (9, 'Omar', 70000); -- DENY (insert revoked)
REVERT;



