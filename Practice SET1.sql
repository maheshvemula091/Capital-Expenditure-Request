--🏗️ CapEx SQL Practice Questions

/*
1️ CapExRequests
RequestId (PK)
RequestNumber
RequestedBy (UserId)
DivisionId
RequestTypeId
Amount
Status        -- Pending / Approved / Rejected
RequestDate
*/

CREATE DATABASE CapEx3
USE CapEx3

CREATE TABLE tblRequest(
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    RequestNumber NVARCHAR(100),
    RequestedBy INT,
    DivisionID INT,
    RequestTypeID INT,
    Amount DECIMAL(18,2),
    ReqStatus NVARCHAR(200),
    RequestDate DATETIME2)

ALTER TABLE tblRequest
ALTER COLUMN RequestNumber NVARCHAR(100)

ALTER TABLE tblRequest
ADD CONSTRAINT Df_tblRequest_RequestDate DEFAULT GETDATE() FOR RequestDate

INSERT INTO tblRequest
(RequestNumber, RequestedBy, DivisionId, RequestTypeId, Amount, ReqStatus, RequestDate)
VALUES
('CAPEX-001', 1, 1, 1, 150000, 'Pending',  '2024-01-05'),
('CAPEX-002', 2, 2, 1, 300000, 'Approved', '2024-01-10'),
('CAPEX-003', 3, 3, 2, 50000,  'Rejected', '2024-01-12'),
('CAPEX-004', 4, 4, 2, 450000, 'Approved', '2024-02-01'),
('CAPEX-005', 1, 1, 1, 200000, 'Approved', '2024-02-15'),
('CAPEX-006', 5, 1, 3, 120000, 'Pending',  '2024-03-01'),
('CAPEX-007', 2, 2, 2, 80000,  'Approved', '2024-03-05'),
('CAPEX-008', 6, 5, 1, 60000,  'Pending',  '2024-03-10'),
('CAPEX-009', 3, 3, 3, 90000,  'Approved', '2024-03-18'),
('CAPEX-010', 4, 4, 1, 250000, 'Approved', '2024-04-01');

--2️ Users
--UserId (PK)
--UserName
--Email
--DivisionId

CREATE TABLE tblUsers(
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName NVARCHAR(200),
    Email NVARCHAR(250),
    DivisionID INT)

ALTER TABLE tblUsers
ADD CONSTRAINT uq_tblUsers_Email UNIQUE (Email)

SET IDENTITY_INSERT tblUsers ON
INSERT INTO tblUsers (UserId, UserName, Email, DivisionId)
VALUES
(1, 'Ravi',  'ravi@company.com', 1),
(2, 'Anita', 'anita@company.com', 2),
(3, 'Kiran', 'kiran@company.com', 3),
(4, 'Suresh','suresh@company.com', 4),
(5, 'Meena', 'meena@company.com', 1),
(6, 'John',  'john@company.com', 5);

SET IDENTITY_INSERT tblUsers OFF


--3️ Divisions
--DivisionId (PK)
--DivisionName

CREATE TABLE tblDivisions(
    DivisionID INT PRIMARY KEY IDENTITY(1,1),
    DivisionName NVARCHAR(200))

INSERT INTO tblDivisions (DivisionName)
VALUES
('Engineering'),
('Operations'),
('Finance'),
('IT'),
('HR');


--4️ CapExApprovals
--ApprovalId (PK)
--RequestId (FK)
--ApproverId (UserId)
--ApprovalLevel
--ApprovalStatus   -- Pending / Approved / Rejected
--ApprovalDate


CREATE TABLE tblCapEXApproval(
    ApprovalID INT PRIMARY KEY IDENTITY(1,1),
    RequestID INT,
    ApproverID INT,
    ApprovalLevel INT,
    ApprovalStatus NVARCHAR(100),
    ApprovalDate DATETIME2)

ALTER TABLE tblCapExApproval
ADD CONSTRAINT Fk_tblCapExApproval_RequestID FOREIGN KEY (RequestID) REFERENCES tblRequest(RequestID)

INSERT INTO tblCapExApproval
(RequestId, ApproverId, ApprovalLevel, ApprovalStatus, ApprovalDate)
VALUES
(2,  3, 1, 'Approved', '2024-01-11'),
(2,  4, 2, 'Approved', '2024-01-12'),
(4,  3, 1, 'Approved', '2024-02-02'),
(4,  4, 2, 'Approved', '2024-02-05'),
(5,  3, 1, 'Approved', '2024-02-16'),
(7,  3, 1, 'Approved', '2024-03-06'),
(7,  4, 2, 'Approved', '2024-03-08'),
(9,  3, 1, 'Approved', '2024-03-20'),
(10, 3, 1, 'Approved', '2024-04-02'),
(10, 4, 2, 'Approved', '2024-04-04');


/* =========================================================
   CapEx SQL Practice Questions
   Write your answer BELOW each question
   ========================================================= */

/* ======================
   BASIC LEVEL
   ====================== */

/* Q1: Insert a new CapEx request (ignore identity column)
   - Status = 'Pending'
   - Amount = 150000
*/
INSERT INTO tblRequest(RequestNumber,RequestedBy,DivisionID,RequestTypeID,Amount,ReqStatus)
VALUES('CAPEX-011', 3, 4, 1, 150000, 'Pending')

/* Q2: Fetch all Pending CapEx requests
   Show: RequestNumber, Amount, RequestDate
*/
SELECT 
    RequestNumber,
    Amount,
    RequestDate    
FROM tblRequest
WHERE ReqStatus = 'Pending'


/* Q3: Count CapEx requests per status
   (Pending, Approved, Rejected)
*/
SELECT ReqStatus,COUNT(*) FROM tblRequest
GROUP BY ReqStatus


/* Q4: Find all CapEx requests raised today */
SELECT * FROM tblRequest
WHERE DAY(RequestDate) = DAY(GETDATE())


/* Q5: Get distinct divisions that raised CapEx requests */
SELECT distinct d.DivisionID FROM tblRequest r
JOIN tblUsers u ON r.RequestedBy = u.UserID
JOIN tblDivisions d ON d.DivisionID = u.DivisionID


/* ======================
   INTERMEDIATE LEVEL
   ====================== */

/* Q6: Approved CapEx amount per division
   Show DivisionName and Total Approved Amount
*/
SELECT r.DivisionID,SUM(r.Amount) as [Total Approved Amount] FROM tblRequest r
JOIN tblDivisions d ON r.DivisionID = d.DivisionID
WHERE r.ReqStatus = 'Approved'
GROUP BY r.DivisionID

/* Q7: Find CapEx requests not yet approved by anyone
   (No entry in CapExApprovals table)
*/
SELECT r.* FROM tblRequest r
LEFT JOIN tblCapEXApproval c
ON r.RequestID = c.RequestID
WHERE c.RequestID IS NULL


/* Q8: Latest CapEx request per user
   Show UserName and latest RequestDate
*/
SELECT u.UserName,MAX(r.RequestDate) AS [Latest RequestDate] FROM tblRequest r
JOIN tblUsers u ON r.RequestedBy = u.UserID
GROUP BY U.UserName


/* Q9: CapEx requests pending at approval level 2 */
SELECT r.* FROM tblRequest r
JOIN tblCapEXApproval c
ON r.RequestID = c.RequestID
WHERE c.ApprovalStatus = 'Pending' AND c.ApprovalLevel = 2

UPDATE tblRequest
SET RequestedBy = 5
WHERE RequestID = 8

/* Q10: Users who never raised a CapEx request */
SELECT U.* FROM tblRequest r
RIGHT JOIN tblUsers u
ON r.RequestedBy = u.UserID
WHERE r.RequestedBy IS NULL

SELECT u.* FROM tblUsers u
WHERE NOT EXISTS(SELECT 1 FROM tblRequest r
WHERE r.RequestedBy = u.UserID)


/* ======================
   ADVANCED LEVEL
   ====================== */

/* Q11: Find divisions with ZERO approved CapEx
   Use NOT EXISTS
*/
SELECT * FROM tblDivisions d
WHERE NOT EXISTS(SELECT 1 FROM tblRequest r
WHERE r.DivisionID = d.DivisionID
AND r.ReqStatus = 'Approved')


/* Q12: Top 3 highest CapEx requests per division
   Use ROW_NUMBER()
*/
WITH CapExCTE
AS
(   SELECT *,
ROW_NUMBER() OVER (PARTITION BY DivisionID ORDER BY RequestDate) as rn
FROM tblRequest)
Select * from CapExCTE
where rn <= 3


/* Q13: Running total of approved CapEx amount by month */
SELECT
    FORMAT(RequestDate, 'yyyy-MM') AS Month,
    SUM(Amount) AS MonthlyAmount,
    SUM(SUM(Amount)) OVER (ORDER BY FORMAT(RequestDate, 'yyyy-MM')
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS RunningTotal
FROM tblRequest
WHERE ReqStatus = 'Approved'
GROUP BY FORMAT(RequestDate, 'yyyy-MM');




/* Q14: Detect duplicate CapEx requests
   Same RequestedBy, Amount, RequestDate
*/
WITH DuplicateCTE 
AS(
    SELECT *,
    ROW_NUMBER()OVER (PARTITION BY RequestedBy,Amount,RequestDate ORDER BY RequestID) as rn
    FROM tblRequest)
SELECT * FROM DuplicateCTE
WHERE rn >1


/* Q15: Find CapEx requests where approval took more than 7 days */
SELECT r.RequestNumber,
    r.RequestDate,
    DATEDIFF(DAY,RequestDate,MAX(ApprovalDate)) AS Datedif
FROM tblRequest r
JOIN tblCapEXApproval c 
ON r.RequestID = c.RequestID
GROUP BY r.RequestNumber,r.RequestDate
HAVING DATEDIFF(DAY,RequestDate,MAX(ApprovalDate)) > 1



/* ======================
   PERFORMANCE / REAL-TIME
   ====================== */

/* Q16: Write a query that causes a TABLE SCAN
   Then rewrite it to use an INDEX SEEK
*/
SELECT * FROM tblRequest
WHERE YEAR(RequestDate) = 2024

SELECT * FROM tblRequest
WHERE RequestDate >= '2024-01-01' AND RequestDate < '2025-01-01'

/* Q17: Suggest a missing index for the below filter
   WHERE Status = 'Approved'
     AND RequestDate BETWEEN @FromDate AND @ToDate
     AND DivisionId = @DivisionId
*/



/* Q18: CapEx dashboard query is slow
   Explain tuning steps (write as comments)
*/
-- 1. Identify slow query using Query Store
-- 2. Analyze execution plan (scan vs seek)
-- 3. Remove functions from WHERE clause
-- 4. Add missing composite index
-- 5. Update statistics
-- 6. Check blocking and parameter sniffing


/* ======================
   STORED PROCEDURE PRACTICE
   ====================== */

/* Q19: Create a stored procedure
   Inputs: @DivisionId, @FromDate, @ToDate
   Output: Total Approved Amount
*/
GO
-- EXEC uspCapExRequest 1,'2024-01-01','2024-03-01'
CREATE OR ALTER PROC uspCapExRequest
    (@DivisionID INT,
    @FromDate DATETIME2,
    @ToDate DATETIME2)
AS
BEGIN
    SELECT SUM(Amount) FROM tblRequest
    WHERE DivisionID = @DivisionID 
    AND ReqStatus = 'Approved'
    AND RequestDate >= @FromDate
    AND RequestDate <= @ToDate
END

/* Q20: Handle parameter sniffing in the above procedure */
--OPTION(RECOMPILE)

/*
OPTION (RECOMPILE) forces SQL Server to recompile the query every time, preventing parameter sniffing and using actual runtime values. 
It improves performance in skewed data scenarios but increases CPU due to recompilation.
*/

/* =========================================================
   END OF PRACTICE
   ========================================================= */
