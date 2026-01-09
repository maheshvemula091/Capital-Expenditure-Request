/*****************************************************************************************
 SECTION 28 – DATA INTEGRITY, CONSTRAINTS & VALIDATIONS
******************************************************************************************/

-- Q48. Add a CHECK constraint to CapExRequest:
-- Ensure Status can be only:
-- ('Draft', 'Submitted', 'Approved', 'Rejected')
ALTER TABLE tblCapExRequest
ADD CONSTRAINT CK_CapEx_ReqStatus CHECK (ReqStatus IN ('Draft','Submitted','Approved','Rejected'))



-- Q49. Add a UNIQUE constraint:
-- Prevent duplicate CapEx titles per division
ALTER TABLE tblCapExRequest
ADD CONSTRAINT UQ_CapEx_tblCapExRequest_Title UNIQUE (Title)


-- Q50. Add ON DELETE / ON UPDATE rules:
-- Prevent deletion of Users if CapEx requests exist

ALTER TABLE tblCapExRequest
ADD CONSTRAINT FK_CapEx_tblCapExRequest_RequestedBy FOREIGN KEY (RequestedBy) REFERENCES tblUsers(UserID)
ON DELETE NO ACTION
ON UPDATE NO ACTION




/*****************************************************************************************
 SECTION 29 – TEMP TABLES & TABLE VARIABLES
******************************************************************************************/

-- Q51. Use a TEMP TABLE:
-- Store all Approved CapEx requests
-- Then query total amount per division
CREATE TABLE #tblCapExApprovedRequest(
	RequestID INT,
	Title VARCHAR(200),
	RequestedBy INT,
	Amount DECIMAL(18,2),
	ReqStatus VARCHAR(30),
	CreatedDate DATETIME)

INSERT INTO #tblCapExApprovedRequest
SELECT RequestID,Title,RequestedBy,Amount,ReqStatus,CreatedDate
FROM tblCapExRequest
WHERE ReqStatus = 'Approved'

-- Q52. Rewrite Q51 using a TABLE VARIABLE
-- Explain difference in comments
GO
DECLARE @tblCapExApprovedRequest TABLE (
	RequestID INT,
	Title VARCHAR(200),
	RequestedBy INT,
	Amount DECIMAL(18,2),
	ReqStatus VARCHAR(30),
	CreatedDate DATETIME)

INSERT INTO @tblCapExApprovedRequest
SELECT RequestID,Title,RequestedBy,Amount,ReqStatus,CreatedDate
FROM tblCapExRequest
WHERE ReqStatus = 'Approved'

SELECT * FROM @tblCapExApprovedRequest

GO
/*****************************************************************************************
 SECTION 30 – DATE & TIME LOGIC
******************************************************************************************/

-- Q53. Write queries to:
-- a) Get CapEx requests created in current month
-- b) Get requests from previous fiscal year
-- c) Calculate number of days request stayed in Pending status
SELECT * FROM tblCapExRequest
WHERE MONTH(CreatedDate) = MONTH(GETDATE())

SELECT *	
FROM tblCapExRequest
WHERE YEAR(CreatedDate) = YEAR(GETDATE()) - 1

SELECT *,
	DATEDIFF(DAY,CreatedDate,GETDATE()) AS DaysRequestStayed 
	FROM tblCapExRequest
WHERE ReqStatus = 'Draft'


/*****************************************************************************************
 SECTION 31 – NULL HANDLING & DATA CLEANING
******************************************************************************************/

-- Q54. Use ISNULL / COALESCE:
-- Replace NULL UtilizedAmount with 0
-- Show impact in budget calculations
SELECT UserID,UserName,Email,DivisionID,COALESCE(CreatedDate,GETDATE()) as CreatedDate FROM tblUsers


-- Q55. Identify:
-- CapEx requests with missing approval records
SELECT * FROM tblCapExRequest r
WHERE NOT EXISTS(SELECT 1 FROM tblApprovalHistory a
WHERE a.RequestID = r.RequestID)


/*****************************************************************************************
 SECTION 32 – MERGE STATEMENT (UPSERT)
******************************************************************************************/

-- Q56. Write a MERGE statement:
-- Source: New budget data
-- Target: Budget table
-- Perform INSERT or UPDATE accordingly
MERGE #tblCapExApprovedRequest AS T
USING tblCapExRequest AS S
ON T.RequestID = S.RequestID

WHEN MATCHED THEN
UPDATE SET T.Amount = 25800;


/*****************************************************************************************
 SECTION 33 – JSON & XML (BASIC)
******************************************************************************************/

-- Q57. Store CapEx request metadata as JSON
-- Extract values using JSON_VALUE()

CREATE TABLE tblCapExRequestJson(
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    Title VARCHAR(200),
    Amount DECIMAL(18,2),
    Metadata NVARCHAR(MAX)   -- JSON stored here
);

INSERT INTO tblCapExRequestJson (Title, Amount, Metadata)
VALUES
('Laptop Purchase', 50000,
N'{
   "divisionId": 2,
   "requestedBy": 15,
   "assetType": "IT",
   "fiscalYear": 2024,
   "priority": "High"
}');
SELECT RequestID,
       Title,
       Amount,

       JSON_VALUE(Metadata,'$.divisionId')     AS DivisionId,
       JSON_VALUE(Metadata,'$.requestedBy')    AS RequestedBy,
       JSON_VALUE(Metadata,'$.assetType')      AS AssetType,
       JSON_VALUE(Metadata,'$.fiscalYear')     AS FiscalYear,
       JSON_VALUE(Metadata,'$.priority')       AS Priority
FROM tblCapExRequestJson;


-- Q58. Convert CapEx request data to XML format

SELECT RequestID,
       Title,
       Amount,
       ReqStatus,
       CreatedDate
FROM tblCapExRequest
FOR XML PATH('Request'), ROOT('CapExRequests');


/*****************************************************************************************
 SECTION 34 – ERROR SCENARIOS & DEBUGGING
******************************************************************************************/

-- Q59. Simulate an error inside a transaction
-- Show how TRY...CATCH captures:
-- ERROR_MESSAGE()
-- ERROR_NUMBER()

BEGIN TRY
    BEGIN TRAN
    INSERT INTO tblCapExRequest(Title,RequestedBy,Amount,ReqStatus,CreatedDate)
    VALUES
    ('Title1',3,25000,'Draft',GETDATE())
    COMMIT
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS Err_Message,
    ERROR_NUMBER() AS Err_Number
    ROLLBACK
END CATCH

-- Q60. Explain in comments:
-- Difference between THROW and RAISERROR

/*
THROW is the modern error-handling statement in SQL Server that 
immediately stops execution and preserves complete error details, unlike RAISERROR.
*/

/*****************************************************************************************
 SECTION 35 – SECURITY & BEST PRACTICES
******************************************************************************************/

-- Q61. Create a SQL ROLE:
-- FinanceRole
-- Grant SELECT on Budget and CapExRequest
/*
A SQL role is a permission group that simplifies security management by assigning permissions 
once and applying them to multiple users.”
*/

SELECT 
    SUSER_SNAME() AS LoginName,
    USER_NAME()   AS DatabaseUser;

CREATE ROLE CapExApprover

GRANT SELECT 
ON tblCapExRequest
TO CapExApprover

GRANT SELECT 
ON tblBudget
TO CapExApprover




-- Q62. Explain in comments:
-- Why dynamic SQL can cause SQL Injection
-- How sp_executesql prevents it

/*
“Dynamic SQL causes SQL injection when user input is concatenated into query strings.
sp_executesql prevents this by parameterizing inputs, separating code from data, 
and ensuring user values are treated as parameters instead of executable SQL.”
*/

/*****************************************************************************************
 SECTION 36 – ADVANCED QUERY CHALLENGES
******************************************************************************************/

-- Q63. Write a query to:
-- Find CapEx requests where Amount > Average Amount of that division
SELECT * FROM
tblCapExRequest
WHERE Amount > (SELECT AVG(Amount) FROM tblCapExRequest c
    JOIN tblUsers u ON c.RequestedBy = u.DivisionID
    JOIN tblDivision d ON u.DivisionID = d.DivisionID)


-- Q64. Identify:
-- Divisions with zero CapEx requests in last 6 months
SELECT * FROM tblDivision d
WHERE NOT EXISTS (SELECT 1 FROM tblUsers u 
    JOIN tblCapExRequest c ON c.RequestedBy = u.UserID
    WHERE u.DivisionID = d.DivisionID) 


SELECT DISTINCT d.DivisionID, d.DivisionName
FROM tblDivision d
LEFT JOIN tblUsers u
       ON d.DivisionID = u.DivisionID
LEFT JOIN tblCapExRequest c
       ON u.UserID = c.RequestedBy
WHERE c.RequestID IS NULL;



-- Q65. Write a query to:
-- Detect duplicate asset values across different requests

SELECT * FROM
    (SELECT 
    COUNT(a.AssetID)OVER (PARTITION BY AssetID) AS Rn
    FROM tblAsset a
    JOIN tblCapExRequest c
    ON a.AssetID = c.RequestID) T

WHERE Rn >1

GO


/*****************************************************************************************
 SECTION 37 – REAL-WORLD CAPEX SCENARIOS
******************************************************************************************/

-- Q66. Business Rule:
-- A division cannot approve more than 3 CapEx requests per month
-- Write SQL logic or procedure to enforce this rule



-- Q67. Write a query to:
-- Identify bottleneck approvers
-- (Approvers with highest pending approvals)



/*****************************************************************************************
 SECTION 38 – FINAL THINKING QUESTIONS (COMMENTS ONLY)
******************************************************************************************/

-- Q68. Explain in comments:
-- How you would migrate this database to a new server
-- With minimal downtime



-- Q69. Explain in comments:
-- How indexing strategy would change
-- If CapExRequest grows to millions of rows



-- Q70. Explain in comments:
-- How Nintex workflows interact with SQL procedures
-- In an enterprise environment



/******************************************** END OF EXTENDED ADVANCED TEST ***************/
