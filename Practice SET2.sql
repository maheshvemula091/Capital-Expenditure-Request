/* =========================================================
   CAPEX BUILDING PROJECT – SQL PRACTICE QUESTION PAPER
   Instructions:
   1. Read each question (in comments)
   2. Write your SQL answer below the question
   3. Do NOT remove the comments
   ========================================================= */


/* =========================================================
   SECTION A – DATABASE DESIGN
   ========================================================= */
   CREATE DATABASE CapEx4
   USE CapEx4
/* Q1:
   Create a table to store CapEx Building Projects with:
   - ProjectID (PK)
   - ProjectName
   - DivisionID
   - BudgetAmount
   - StartDate
   - EndDate
   - ReqStatus
*/
CREATE TABLE tblCapExPro(
	ProjectID INT PRIMARY KEY IDENTITY(1,1),
	projectName NVARCHAR(500),
	DivisionID INT,
	BudgetAmount DECIMAL(18,2),
	StartDate DATETIME2,
	EndDate DATETIME2,
	ProStatus VARCHAR(100))



/* Q2:
   Create a table to store CapEx Requests with:
   - RequestID (PK)
   - ProjectID (FK)
   - RequestedBy (UserID)
   - ReqAmount
   - RequestDate
   - ReqStatus
   Ensure proper primary and foreign keys.
*/
CREATE TABLE tblCapExRequest(
	RequestID INT PRIMARY KEY IDENTITY(1,1),
	ProjectID INT,
	RequestedBy INT,
	ReqAmount DECIMAL(18,2),
	ReqDate DATETIME2,
	ReqStatus VARCHAR(100))

ALTER TABLE tblCapExRequest
ADD CONSTRAINT Fk_tblCapExRequest_ProjectID FOREIGN KEY (ProjectID) REFERENCES tblCapExPro(ProjectID)

ALTER TABLE tblCapExRequest
ADD CONSTRAINT Fk_tblCapExRequest_RequestedBy FOREIGN KEY (RequestedBy) REFERENCES tblUsers(UserID)

CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(100),
    DivisionID INT
);

Exec sp_rename 'Users','tblUsers'
/* Q3:
   Create a table to store CapEx Approval History.
   Each CapEx request can have multiple approvals.
*/
CREATE TABLE CapExApprovalHistory (
    ApprovalID INT PRIMARY KEY,
    RequestID INT,
    ApprovedBy INT,
    ApprovalDate DATE,
    ApprovalStatus VARCHAR(30),
    FOREIGN KEY (RequestID) REFERENCES tblCapExRequest(RequestID)
);




/* Q4:
   Add a constraint to ensure ReqAmount is always greater than zero.
*/
ALTER TABLE tblCapExRequest
ADD CONSTRAINT CK_tblCapExRequest CHECK (ReqAmount > 0)



/* =========================================================
   SECTION B – DATA MANIPULATION
   ========================================================= */

/* Q5:
   Insert sample data:
   - 3 Projects
   - 5 Users
   - 6 CapEx Requests
*/
INSERT INTO tblCapExPro VALUES
('Office Building', 1, 5000000, '2024-01-01', '2025-01-01', 'Active'),
('Warehouse', 2, 3000000, '2024-02-01', '2025-02-01', 'Active'),
('R&D Center', 1, 8000000, '2024-03-01', '2026-03-01', 'Planned');

INSERT INTO tblUsers VALUES
(101, 'Mahesh', 1),
(102, 'Anita', 2),
(103, 'Ravi', 1),
(104, 'Suresh', 2),
(105, 'Kiran', 1);

INSERT INTO tblCapExRequest VALUES
(1, 101, 500000, '2024-01-10', 'Pending'),
(1, 103, 1200000, '2024-01-15', 'Approved'),
(2, 102, 800000, '2023-11-20', 'Rejected'),
(2, 104, 600000, '2024-02-05', 'Pending'),
(3, 105, 1500000, '2024-03-10', 'Approved'),
(3, 101, 2000000, '2024-03-15', 'Pending');



/* Q6:
   Update all CapEx requests:
   - ReqStatus = 'Expired'
   - Where ReqStatus is 'Pending'
   - And request date is older than 30 days
*/
UPDATE tblCapExRequest
SET ReqStatus = 'Expired'
WHERE ReqStatus = 'Pending' AND DATEDIFF(DAY,ReqDate,GETDATE()) > 30 


/* Q7:
   Delete CapEx requests that are:
   - ReqStatus = 'Rejected'
   - RequestDate before year 2023
*/
DELETE FROM tblCapExRequest
WHERE ReqStatus = 'Rejected' AND YEAR(ReqDate) <= 2023




/* Q8:
   Increase project budget by 10%
   for projects belonging to Engineering division.
*/
UPDATE tblCapExPro
SET BudgetAmount = BudgetAmount + BudgetAmount * 0.1
WHERE DivisionID = 1



/* =========================================================
   SECTION C – SELECT & JOIN QUERIES
   ========================================================= */

/* Q9:
   Display CapEx request details along with:
   - Project Name
   - Requested User Name
   - Division Name
*/
SELECT ProjectName,RequestedBy As RequestorName,r.* FROM tblCapExPro p
Join tblCapExRequest r ON p.ProjectID =r.ProjectID
JOIN tblUsers u ON u.UserID = r.RequestedBy




/* Q10:
   Find total CapEx request amount per project.
*/
SELECT  p.ProjectID,SUM(r.ReqAmount) AS AmountPerPro FROM tblCapExRequest r
join tblCapExPro p ON r.ProjectID = p.ProjectID
GROUP BY p.ProjectID



/* Q11:
   List projects that have NO CapEx requests.
*/
SELECT * FROM tblCapExPro p 
WHERE NOT EXISTS (SELECT 1 FROM tblCapExRequest r
	WHERE P.ProjectID = r.ProjectID)



/* Q12:
   Display CapEx requests where
   request amount is greater than
   the average request amount of that project.
*/
SELECT *
FROM (
    SELECT *,
           AVG(ReqAmount) OVER (PARTITION BY ProjectID) AS AvgAmount
    FROM tblCapExRequest
) t
WHERE ReqAmount > AvgAmount;



/* Q13: Latest request per project */
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ProjectID ORDER BY RequestDate DESC) AS rn
    FROM tblCapExRequest
) t
WHERE rn = 1;



/* =========================================================
   SECTION D – ADVANCED SQL
   ========================================================= */

/* Q14: Rank requests project-wise */
SELECT
    RequestID,
    ProjectID,
    ReqAmount,
    RANK() OVER (PARTITION BY ProjectID ORDER BY ReqAmount DESC) AS AmountRank
FROM tblCapExRequest;


/* Q15: Top 2 requests per division */
SELECT *
FROM (
    SELECT
        r.RequestID,
        u.DivisionID,
        r.ReqAmount,
        ROW_NUMBER() OVER (PARTITION BY u.DivisionID ORDER BY r.ReqAmount DESC) AS rn
    FROM tblCapExRequest r
    JOIN Users u ON r.RequestedBy = u.UserID
) t
WHERE rn <= 2;


/* Q16: Pivot request amount ReqStatus-wise */
SELECT *
FROM (
    SELECT ProjectID, ReqStatus, ReqAmount
    FROM tblCapExRequest
) src
PIVOT (
    SUM(ReqAmount)
    FOR ReqStatus IN ([Pending], [Approved], [Rejected])
) p;


/* Q17: Stored Procedure */
CREATE PROC uspGetCapExByDivisionAndDate
    @DivisionID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT r.*
    FROM tblCapExRequest r
    JOIN Users u ON r.RequestedBy = u.UserID
    WHERE u.DivisionID = @DivisionID
      AND r.ReqDate BETWEEN @StartDate AND @EndDate;
END;


/* Q18: Scalar function for 5% contingency */
CREATE FUNCTION dbo.fn_Contingency (@Amount DECIMAL(14,2))
RETURNS DECIMAL(14,2)
AS
BEGIN
    RETURN @Amount * 0.05;
END;



/* =========================================================
   SECTION E – REAL-TIME SCENARIOS
   ========================================================= */

/* Q19: Transaction with rollback */
BEGIN TRY
    BEGIN TRAN;

    INSERT INTO tblCapExRequest
    VALUES (7, 1, 101, 700000, GETDATE(), 'Pending');

    INSERT INTO CapExApprovalHistory
    VALUES (1, 7, 102, GETDATE(), 'Pending');

    COMMIT TRAN;
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
END CATCH;
