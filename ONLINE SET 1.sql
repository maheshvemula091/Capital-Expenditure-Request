/*****************************************************************************************
 CapExDB 2.0 – SQL Server Hands-On Test
 Experience Level: 2 Years
 Database: CapEx2
 Time: 90–120 Minutes

 Instructions:
 1. Read each section carefully.
 2. Write SQL code below each question.
 3. Do NOT remove questions or comments.
 4. Follow proper naming conventions.
 5. Use appropriate data types, constraints, PK, FK.
******************************************************************************************/

/*****************************************************************************************
 SECTION 1 – DATABASE CREATION
******************************************************************************************/

-- Q1. Create a database named CapEx2
-- Need to understand More about Create Database
CREATE DATABASE CapEx2

-- Switch to CapEx2 database
USE CapEx2
GO



/*****************************************************************************************
 SECTION 2 – ORGANIZATION & USERS MODULE
******************************************************************************************/

-- Q2. Create table: Division
-- Columns:
-- DivisionID (INT, PK, Identity)
-- DivisionName (VARCHAR(100), NOT NULL)
-- IsActive (BIT, Default = 1)
-- CreatedDate (DATETIME, Default = GETDATE())
CREATE TABLE tblDivision(
	DivisionID INT IDENTITY PRIMARY KEY,
	DivisionName VARCHAR(100) NOT NULL,
	IsActive BIT,
	CreateDate DATETIME)

ALTER TABLE tblDivision
ADD CONSTRAINT Df_tblDivision_IsActive DEFAULT 1  FOR IsActive

ALTER TABLE tblDivision
ADD CONSTRAINT Df_tblDivision_CreateDate DEFAULT GETDATE() FOR CreateDate


-- Q3. Create table: Users
-- Columns:
-- UserID (INT, PK, Identity)
-- UserName (VARCHAR(100), NOT NULL)
-- Email (VARCHAR(150), UNIQUE)
-- Role (VARCHAR(50))
-- DivisionID (INT, FK → Division)
-- CreatedDate (DATETIME, Default = GETDATE())

CREATE TABLE tblUsers(
	UserID INT IDENTITY(1,1) PRIMARY KEY,
	UserName VARCHAR(100) NOT NULL,
	Email VARCHAR(150),
	UserRole VARCHAR(50),
	DivisionID INT,
	CreatedDate DATETIME)

ALTER TABLE tblUsers 
ADD CONSTRAINT Uq_tblUsers_Email UNIQUE (Email)

ALTER TABLE tblUsers
ADD CONSTRAINT FK_tblUsers_DivisionID FOREIGN KEY (DivisionID) REFERENCES tblDivision(DivisionID)

ALTER TABLE tblUsers
ADD CONSTRAINT Df_tblUsers_CreatedDate DEFAULT GETDATE() FOR CreatedDate


/*****************************************************************************************
 SECTION 3 – CAPEX REQUESTS MODULE
******************************************************************************************/

-- Q4. Create table: CapExRequest
-- Columns:
-- RequestID (INT, PK, Identity)
-- Title (VARCHAR(200), NOT NULL)
-- RequestedBy (INT, FK → Users)
-- Amount (DECIMAL(18,2), CHECK Amount > 0)
-- Status (VARCHAR(30), Default = 'Draft')
-- CreatedDate (DATETIME, Default = GETDATE())
CREATE TABLE tblCapExRequest(
	RequestID INT PRIMARY KEY IDENTITY(1,1),
	Title VARCHAR(200) NOT NULL,
	RequestedBy INT,
	Amount DECIMAL(18,2),
	ReqStatus VARCHAR(30),
	CreatedDate DATETIME)

ALTER TABLE tblCapExRequest
ADD CONSTRAINT FK_tblCapExRequest_RequestedBy FOREIGN KEY (RequestedBy) REFERENCES tblUsers(UserID)

ALTER TABLE tblCapExRequest
ADD CONSTRAINT Ck_tblCapExRequest_Amount CHECK (Amount > 0)

ALTER TABLE tblCapExRequest
ADD CONSTRAINT Df_tblCapExRequest_ReqStatus DEFAULT 'Draft' FOR ReqStatus

ALTER TABLE tblCapExRequest
ADD CONSTRAINT Df_tblCapExRequest_CreatedDate DEFAULT GETDATE() FOR CreatedDate




/*****************************************************************************************
 SECTION 4 – APPROVAL WORKFLOW MODULE
******************************************************************************************/

-- Q5. Create table: ApprovalHistory
-- Columns:
-- ApprovalID (INT, PK, Identity)
-- RequestID (INT, FK → CapExRequest)
-- ApproverID (INT, FK → Users)
-- ApprovalLevel (INT)
-- Action (VARCHAR(20))
-- ActionDate (DATETIME, Default = GETDATE())
CREATE TABLE tblApprovalHistory(
	ApprovalID INT PRIMARY KEY IDENTITY(1,1),
	RequestID INT FOREIGN KEY REFERENCES tblCapExRequest(RequestID),
	ApproverID INT FOREIGN KEY REFERENCES tblUsers(UserID),
	ApprovalLevel INT,
	ApprovalAction VARCHAR(20),
	ActionDate DATETIME)

ALTER TABLE tblApprovalHistory
ADD CONSTRAINT Df_tblApprovalHistory_ActionDate DEFAULT GETDATE() FOR ActionDate





/*****************************************************************************************
 SECTION 5 – BUDGET MANAGEMENT MODULE
******************************************************************************************/

-- Q6. Create table: Budget
-- Columns:
-- BudgetID (INT, PK, Identity)
-- DivisionID (INT, FK → Division)
-- FiscalYear (INT)
-- TotalBudget (DECIMAL(18,2))
-- UtilizedAmount (DECIMAL(18,2), Default = 0)
CREATE TABLE tblBudget(
	BudgetID INT PRIMARY KEY IDENTITY(1,1),
	DivisionId INT FOREIGN KEY REFERENCES tblDivision(DivisionID),
	FiscalYear INT,
	TotalBudget DECIMAL(18,2),
	UtilizedAmount DECIMAL(18,2) DEFAULT 0)



/*****************************************************************************************
 SECTION 6 – ASSET MANAGEMENT MODULE
******************************************************************************************/

-- Q7. Create table: Asset
-- Columns:
-- AssetID (INT, PK, Identity)
-- RequestID (INT, FK → CapExRequest)
-- AssetValue (DECIMAL(18,2))
-- PurchaseDate (DATE)
-- UsefulLifeYears (INT)
CREATE TABLE tblAsset(
	AssetID INT PRIMARY KEY IDENTITY(1,1),
	RequestID INT,
	AssetValue DECIMAL(18,2),
	PurchaseDate DATE,
	UsefulLifeYears INT)

ALTER TABLE tblAsset
ADD CONSTRAINT FK_tblAsset_RequestID FOREIGN KEY (RequestID) REFERENCES tblCapExRequest(RequestID)




/*****************************************************************************************
 SECTION 7 – AUDIT & COMPLIANCE MODULE
******************************************************************************************/

-- Q8. Create table: AuditLog
-- Columns:
-- AuditID (INT, PK, Identity)
-- TableName (VARCHAR(100))
-- Action (VARCHAR(50))
-- ActionBy (INT)
-- ActionDate (DATETIME, Default = GETDATE())
CREATE TABLE tblAuditLog(
	AuditID INT PRIMARY KEY IDENTITY(1,1),
	TableName VARCHAR(100),
	AuditLogAction VARCHAR(50),
	ActionBy INT,
	ActionDate DATETIME DEFAULT GETDATE())


/*****************************************************************************************
 SECTION 8 – DUMMY DATA PREPARATION
******************************************************************************************/

-- Q9. Insert dummy data:
-- a) At least 2 divisions
-- b) At least 4 users (Requester, Approver, Finance)
-- c) 3 CapEx requests
-- d) Budget data for each division
-- e) At least 2 approval records
-- f) 1 asset record

INSERT INTO tblDivision(DivisionName,IsActive,CreateDate)
VALUES
('Division1',1,NULL),
('Division2',1,'2025-12-25 19:35'),
('Division3',1,'2024-02-18 02:47')

INSERT INTO tblUsers(UserName,Email,UserRole,DivisionID,CreatedDate)
VALUES
('User1','User1@gamil.com','Requestor',1,NULL),
('User2','User2@gmail.com','Approver',1,NULL),
('User3','User3@gmail.com','Finance',2,NULL),
('User4','User4@gmail.com','Requestor',3,'2025-06-15 12:55')

INSERT INTO tblCapExRequest(Title,RequestedBy,Amount,ReqStatus)
VALUES
('Title1',1,250000,'Pending'),
('Title2',1,548000,'Approved'),
('Title3',2,784000,'Rejected')


INSERT INTO tblBudget(DivisionId,FiscalYear,TotalBudget,UtilizedAmount)
VALUES
(1,2024,10000000,4800000),
(2,2025,15000000,2000000),
(3,2023,14500000,3500000)

INSERT INTO tblApprovalHistory(RequestID,ApproverID,ApprovalLevel,ApprovalAction,ActionDate)
VALUES
(1,1,5,'Approved','2025-12-07 10:23'),
(2,3,4,'Pending','2025-11-04 03:49')

INSERT INTO tblAsset(RequestID,AssetValue,PurchaseDate,UsefulLifeYears)
VALUES
(1,450000,'2025-08-12',5),
(2,760000,'2024-03-12',10)




/*****************************************************************************************
 SECTION 9 – JOINS & QUERIES
******************************************************************************************/

-- Q10. Fetch all CapEx requests with:
-- Request Title
-- Amount
-- Requester Name
-- Division Name
SELECT cr.Title,cr.Amount,u.UserName,d.DivisionName FROM tblCapExRequest cr
JOIN tblUsers u ON cr.RequestID = u.DivisionID
JOIN tblDivision d ON u.DivisionID =d.DivisionID


-- Q11. Get total CapEx amount per division

SELECT SUM(cr.Amount) as AmountPerDivision FROM  tblCapExRequest cr
JOIN tblUsers u ON cr.RequestID = u.DivisionID
JOIN tblDivision d ON u.DivisionID = d.DivisionID
GROUP BY d.DivisionID





-- Q12. List pending approvals with approver name

SELECT u.UserName FROM tblUsers u
JOIN tblApprovalHistory ah ON ah.ApproverID = u.UserID
WHERE ah.ApprovalAction = 'Pending'

/*****************************************************************************************
 SECTION 10 – FUNCTIONS
******************************************************************************************/

-- Q13. Create a scalar function:
-- Name: fn_GetAvailableBudget
-- Input: @DivisionID INT
-- Output: AvailableBudget (TotalBudget - UtilizedAmount)
GO
CREATE FUNCTION fn_tblBudgetAvailableBudgetGet(@DivisionID INT)
RETURNS DECIMAL(18,2)
AS 
BEGIN
	DECLARE @AvailableBudget DECIMAL(18,2)
	SELECT @AvailableBudget = (TotalBudget - UtilizedAmount)  FROM tblBudget
	WHERE DivisionId = @DivisionID
	RETURN @AvailableBudget
END





-- Q14. Write a SELECT query using fn_GetAvailableBudget
GO
SELECT * from fn_tblBudgetGetAvailableBudget(1)

/*****************************************************************************************
 SECTION 11 – STORED PROCEDURES
******************************************************************************************/

-- Q15. Create stored procedure:
-- Name: sp_ApproveCapEx
-- Logic:
-- 1. Validate available budget
-- 2. If sufficient → update request status to 'Approved'
-- 3. Else → throw error
-- Use IF condition and transaction handling
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================
-- AUTHOR: Vemula Mahesh
-- Created Date: 30-12-2025
-- Description: Validation for approval
-- ====================================

ALTER PROC uspCapExGetApproval
	(@DivisionId INT,
	@RequestID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ReqAmount DECIMAL(18,2)
	DECLARE @AvailableBudget DECIMAL(18,2)
	BEGIN TRY
		BEGIN TRAN
		SELECT @ReqAmount = Amount from tblCapExRequest
		WHERE RequestID = @RequestID
		
		SELECT @AvailableBudget = (TotalBudget - UtilizedAmount)  
		FROM tblBudget
		WHERE DivisionId = @DivisionId

		IF @ReqAmount < @AvailableBudget
		BEGIN 
			UPDATE tblApprovalHistory
			SET ApprovalAction = 'Approved'
			WHERE RequestID = @RequestID
		END 
		UPDATE tblBudget
		SET UtilizedAmount = UtilizedAmount + @ReqAmount
		WHERE DivisionId = @DivisionId
		COMMIT TRAN;
	
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		THROW;
	END CATCH
	
END

GO

SELECT * FROM tblApprovalHistory

EXECUTE uspCapExGetApproval 1,2

-- Q16. Create stored procedure:
-- Name: sp_CreateCapExRequest
-- Purpose: Insert a new CapEx request

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================
-- AUTHOR: MAHESH VEMULA
-- CREATED DATE: 02/01/2026
-- DESCRIPTION: Insert a New CapEx Request
-- ==========================================

CREATE PROC uspCapExRequestInsert
	(@Title VARCHAR(200),
	@RequestedBy INT,
	@Amount DECIMAL(18,2),
	@ReqStatus VARCHAR(30))
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO tblCapExRequest(Title,RequestedBy,Amount,ReqStatus)
	VALUES
	(@Title,@RequestedBy,@Amount,@ReqStatus)
END

GO
SELECT * FROM tblCapExRequest
EXEC uspCapExRequestInsert 'title 5',2,25480,'Pending'



/*****************************************************************************************
 SECTION 12 – VIEWS
******************************************************************************************/

-- Q17. Create view: vw_CapExSummary
-- Columns:
-- RequestID, Title, Amount, Status
-- DivisionName
-- RequestedBy (UserName)
GO
CREATE VIEW vw_CapExSummary
AS
	SELECT r.RequestID,r.Title,r.Amount,r.ReqStatus,u.UserName FROM tblCapExRequest r
	LEFT JOIN tblUsers u ON r.RequestedBy = u.UserID
	LEFT JOIN tblDivision d ON u.DivisionID = d.DivisionID
GO
SELECT * FROM vw_CapExSummary

/*****************************************************************************************
 SECTION 13 – TRIGGERS
******************************************************************************************/

-- Q18. Create an AFTER UPDATE trigger on CapExRequest
-- Action:
-- Insert audit record into AuditLog when Status is updated

GO
CREATE OR ALTER TRIGGER tr_CapExRequest ON tblCapExRequest
AFTER UPDATE
AS
BEGIN 
	IF UPDATE(ReqStatus)
	BEGIN
		INSERT INTO tblAuditLog(TableName,AuditLogAction,ActionBy,ActionDate)
		SELECT 'tblCapExRequest','UPDATE',RequestedBy,GETDATE() FROM inserted
	END
END
GO

UPDATE tblCapExRequest
SET ReqStatus = 'Approved'
WHERE ReqStatus = 'Rejected'

SELECT * FROM tblCapExRequest
SELECT * FROM tblAuditLog

/*****************************************************************************************
 SECTION 14 – PERFORMANCE & INDEXING
******************************************************************************************/

-- Q19. Create index on CapExRequest(Status)
GO
CREATE NONCLUSTERED INDEX IX_CapExRequest_ReqStatus 
ON tblCapExRequest(ReqStatus ASC) 


-- Q20. Create index on ApprovalHistory(RequestID)
GO
CREATE NONCLUSTERED INDEX IX_ApprovalHistory_RequestID
ON tblApprovalHistory(RequestID ASC)

/*****************************************************************************************
 SECTION 15 – BACKUP & EXPORT
******************************************************************************************/

-- Q21. Write script to take FULL BACKUP of CapEx2
-- Backup location example: C:\Backup\CapEx2.bak
GO
BACKUP DATABASE CapEx2
TO DISK = 'D:\My Work\Learning\CapExDB_FULL.bak'
WITH INIT;

-- Q22. Explain (in comments):
-- a) How to export table data
-- b) How to restore database from backup

--RESTORE DATABASE CapEx2 
--FROM DISK ='D:\My Work\Learning\CapExDB_FULL.bak'
--WITH NORECOVERY

/******************************************** END OF TEST *********************************/
