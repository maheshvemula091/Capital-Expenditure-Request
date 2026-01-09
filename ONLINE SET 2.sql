/*****************************************************************************************
 CapExDB 2.0 – ADVANCED SQL HANDS-ON TEST (CONTINUATION)
 Experience Level: 2 Years
 Database: CapEx2

 Focus Areas:
 - CTEs
 - Join types
 - Calculations & operators
 - TRY...CATCH & Transactions
 - Cursors
 - Grouping, Ranking, Pivot
 - Scalar & Table-valued Functions
 - Nested Procedures
 - Dynamic SQL
 - Complex real-world queries
******************************************************************************************/

USE CapEx2;
GO

/*****************************************************************************************
 SECTION 16 – JOIN TYPES & CTEs
******************************************************************************************/

-- Q23. Using a CTE:
-- Fetch CapEx requests along with requester name, division name, and approval count
-- Use:
-- a) CTE
-- b) INNER JOIN, LEFT JOIN
-- c) GROUP BY

WITH ApprovalCTE AS
(
    SELECT
        RequestID,
        COUNT(*) AS ApprovalCount
    FROM tblApprovalHistory
    GROUP BY RequestID
)
SELECT
    u.UserName AS RequesterName,
    d.DivisionName,
    ISNULL(a.ApprovalCount, 0) AS ApprovalCount
FROM tblCapExRequest r
INNER JOIN tblUsers u
    ON r.RequestedBy = u.UserID
LEFT JOIN tblDivision d
    ON r.RequestID = d.DivisionID
LEFT JOIN ApprovalCTE a
    ON r.RequestID = a.RequestID



-- Q24. Write separate queries demonstrating:
-- a) INNER JOIN
-- b) LEFT JOIN
-- c) RIGHT JOIN
-- d) FULL OUTER JOIN
-- between CapExRequest and ApprovalHistory
GO
SELECT * FROM tblCapExRequest r
JOIN tblApprovalHistory a ON r.RequestID = a.RequestID

SELECT * FROM tblCapExRequest r
LEFT JOIN tblApprovalHistory a ON r.RequestID = a.RequestID

SELECT * FROM tblCapExRequest r
RIGHT JOIN tblApprovalHistory a ON r.RequestID = a.RequestID

SELECT * FROM tblCapExRequest r
FULL OUTER JOIN tblApprovalHistory a ON r.RequestID = a.RequestID

SELECT * FROM tblCapExRequest r
CROSS JOIN tblApprovalHistory a 


/*****************************************************************************************
 SECTION 17 – ARITHMETIC, LOGICAL & STRING OPERATIONS
******************************************************************************************/

-- Q25. Write a query that displays:
-- RequestID
-- Title
-- Amount
-- Amount with 18% tax added
-- Amount rounded to nearest integer

SELECT RequestID,Title,
	Amount,
	ROUND(Amount+(Amount * 0.18),2) AS AmountWithTax 
	FROM tblCapExRequest


-- Q26. Write a query using string functions:
-- a) Convert Title to UPPER case
-- b) Display first 10 characters of Title
-- c) Concatenate Title with Status

SELECT UPPER(Title) AS Title,
	LEFT(Title,4) AS FirstTenLetters,
	CONCAT(Title,ReqStatus) AS Concatenation 
	FROM tblCapExRequest



-- Q27. Use logical operators:
-- Fetch requests where:
-- Amount > 500000 AND Status <> 'Rejected'
-- OR CreatedDate is within last 30 days

SELECT * FROM tblCapExRequest
WHERE Amount > 500000 AND ReqStatus <> 'Rejected' OR DATEDIFF(DAY,CreatedDate,GETDATE()) < 30


/*****************************************************************************************
 SECTION 18 – TRY...CATCH & TRANSACTIONS
******************************************************************************************/

-- Q28. Create a stored procedure:
-- Name: sp_UpdateBudgetUtilization
-- Logic:
-- 1. Start transaction
-- 2. Update UtilizedAmount in Budget
-- 3. If error occurs → rollback
-- 4. Else → commit
-- Use TRY...CATCH
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =================================
-- AUTHOR: MAHESH VEMULA
-- CREATED DATE: 03-01-2026
-- DESCRIPTION: Creating Stored Procedure for Updating Utilized Amount
-- =================================

CREATE PROC uspBudgetUtilizationUpdate
    (@RequestID INT,
    @DivisionId INT)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN
        DECLARE @ReqAmount DECIMAL(18,2)

        SELECT @ReqAmount = Amount FROM tblCapExRequest
        WHERE RequestID = @RequestID

        UPDATE tblBudget
        SET UtilizedAmount = UtilizedAmount + @ReqAmount
        WHERE DivisionId = @DivisionId

        COMMIT
    END TRY
    BEGIN CATCH
        ROLLBACK
    END CATCH
END

GO
EXEC uspBudgetUtilizationUpdate 1,1

SELECT * FROM tblBudget


-- Q29. Modify sp_ApproveCapEx to include:
-- TRY...CATCH
-- Explicit BEGIN TRANSACTION and COMMIT / ROLLBACK



/*****************************************************************************************
 SECTION 19 – CURSORS
******************************************************************************************/

-- Q30. Write a cursor to:
-- Loop through all Approved CapEx requests
-- For each request:
--   Print RequestID and Amount
-- (Use FAST_FORWARD cursor)

DECLARE @RequestID INT
DECLARE @Amount DECIMAL(18,2)

DECLARE CapEx_Cursor CURSOR FAST_FORWARD
FOR 
SELECT RequestID,Amount FROM tblCapExRequest;

OPEN CapEx_Cursor;

FETCH NEXT FROM CapEx_Cursor INTO @RequestID,@Amount;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @RequestID;
    PRINT @Amount;
    FETCH NEXT FROM CapEx_Cursor INTO @RequestID,@Amount
END;

CLOSE CapEx_Cursor;
DEALLOCATE CapEx_Cursor;


    

-- Q31. Write a cursor-based procedure to:
-- Update UtilizedAmount for each division based on approved requests
GO
CREATE PROC uspBudgetUtlizedAmountUpdateCursor 
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @DivisionId INT
    DECLARE @TotalAmount DECIMAL(18,2)

    DECLARE BudgetUtilized_Cursor CURSOR
    FOR
    SELECT u.DivisionID,SUM(r.Amount) AS TotalAmount FROM tblCapExRequest r
    JOIN tblUsers u ON r.RequestedBy = u.DivisionID
    WHERE r.ReqStatus = 'Approved'
    GROUP BY u.DivisionID

    OPEN BudgetUtilized_Cursor;

    FETCH NEXT FROM BudgetUtilized_Cursor INTO @DivisionId,@TotalAmount;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE tblBudget
        SET UtilizedAmount = UtilizedAmount + @TotalAmount
        WHERE DivisionId = @DivisionId

        FETCH NEXT FROM BudgetUtilized_Cursor INTO @DivisionId,@TotalAmount
    END;

    CLOSE BudgetUtilized_Cursor;
    DEALLOCATE BudgetUtilized_Cursor;
END

GO
EXEC uspBudgetUtlizedAmountUpdateCursor

SELECT * FROM tblBudget
SELECT * FROM tblCapExRequest

/*****************************************************************************************
 SECTION 20 – GROUPING, RANKING & WINDOW FUNCTIONS
******************************************************************************************/

-- Q32. Write a query using GROUP BY:
-- Total CapEx amount per fiscal year and division

SELECT SUM(r.Amount) AS TotalAmount FROM tblCapExRequest r
JOIN tblBudget b ON r.RequestID = b.DivisionId
GROUP BY b.FiscalYear,b.DivisionId


-- Q33. Use window functions:
-- Rank CapEx requests by Amount within each Division
-- Use RANK() or DENSE_RANK()

SELECT
    d.DivisionName,
    c.RequestID,
    c.Title,
    c.Amount,
    DENSE_RANK() OVER (
        PARTITION BY u.DivisionID
        ORDER BY c.Amount DESC
    ) AS AmountRank
FROM tblCapExRequest c
JOIN tblUsers u
    ON c.RequestedBy = u.UserID
JOIN tblDivision d
    ON u.DivisionID = d.DivisionID;



-- Q34. Find:
-- Top 2 highest CapEx requests per division
-- Use ROW_NUMBER()
WITH CapExRanked 
AS(
    SELECT
    d.DivisionName,
    c.RequestID,
    c.Title,
    c.Amount,
    ROW_NUMBER() OVER (
        PARTITION BY u.DivisionID
        ORDER BY c.Amount DESC
    ) AS AmountRank
FROM tblCapExRequest c
JOIN tblUsers u
    ON c.RequestedBy = u.UserID
JOIN tblDivision d
    ON u.DivisionID = d.DivisionID
)

SELECT * FROM CapExRanked
WHERE AmountRank = 2
ORDER BY Amount DESC

/*****************************************************************************************
 SECTION 21 – PIVOTING
******************************************************************************************/

-- Q35. Pivot CapEx amounts:
-- Rows: Division
-- Columns: Status (Draft, Approved, Rejected)
-- Values: SUM(Amount)

SELECT DivisionName,
    Title,
    ISNULL([Approved],0)   AS Approved,
    ISNULL([Rejected],0)   AS Rejected,
    ISNULL([Draft],0)      AS Draft
FROM
(
   SELECT
    d.DivisionName,
    c.ReqStatus,
    c.Title,
    c.Amount 
FROM tblCapExRequest c
JOIN tblUsers u
    ON c.RequestedBy = u.UserID
JOIN tblDivision d
    ON u.DivisionID = d.DivisionID
) AS SourceTable
PIVOT
(
    SUM(Amount)
    FOR ReqStatus IN ([Approved],[Rejected],[Draft])
) AS PivotTable
ORDER BY DivisionName


/*****************************************************************************************
 SECTION 22 – FUNCTIONS (SCALAR & TABLE-VALUED)
******************************************************************************************/

-- Q36. Create a scalar function:
-- Name: fn_CalculateTax
-- Input: @Amount DECIMAL(18,2)
-- Output: 18% tax amount
GO
CREATE FUNCTION fn_CapEx_CalculateTax
    (@Amount DECIMAL(18,2))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TaxAmount DECIMAL(18,2)
    SET @TaxAmount = @Amount * 0.18
    RETURN @TaxAmount
END

GO
SELECT [dbo].[fn_CapEx_CalculateTax](25000) AS [Tax Amount]

-- Q37. Create an inline table-valued function:
-- Name: fn_GetApprovedRequests
-- Returns all approved CapEx requests
GO
CREATE FUNCTION fn_CapExGetApprovedRequests()
RETURNS TABLE
AS
    RETURN(
        SELECT * FROM tblCapExRequest
        WHERE ReqStatus = 'Approved')
GO

SELECT * FROM [dbo].[fn_CapExGetApprovedRequests]()


-- Q38. Call fn_CalculateTax inside:
-- a) SELECT query
-- b) Stored procedure
GO
CREATE PROC uspCapExCalculateTax(@Amount DECIMAL(18,2))
AS
BEGIN
    SELECT [dbo].[fn_CapEx_CalculateTax](@Amount) AS [Tax Amount]
END

EXEC uspCapExCalculateTax 25000

/*****************************************************************************************
 SECTION 23 – PROCEDURE INSIDE PROCEDURE
******************************************************************************************/

-- Q39. Create a procedure:
-- Name: sp_ProcessCapEx
-- Logic:
-- 1. Call sp_ApproveCapEx
-- 2. Call sp_UpdateBudgetUtilization
-- Pass parameters between procedures
GO
CREATE PROC uspCapExProcess
    (@DivisionID INT,
    @RequestID INT)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRAN
        EXEC uspCapExGetApproval @DivisionId =@DivisionID,@RequestID = @RequestID
        EXEC uspBudgetUtilizationUpdate @RequestID =@RequestID,@DivisionId =@DivisionID
        COMMIT
    END TRY
    BEGIN CATCH
        ROLLBACK
    END CATCH

END

EXEC uspCapExProcess 1,1
-- Q40. Modify sp_CreateCapExRequest:
-- Add default parameters for Status and CreatedDate
GO

CREATE PROC uspCapExRequestCreate
    (@Title VARCHAR(200),
    @RequestedBy INT,
    @Amount DECIMAL(18,2),
    @ReqStatus VARCHAR(30) = 'DRAFT',
    @CreatedDate DATETIME = NULL)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRAN
        IF @CreatedDate IS NULL
           SET @CreatedDate = GETDATE()
        INSERT INTO tblCapExRequest(Title,RequestedBy,Amount,ReqStatus,CreatedDate)
        VALUES 
        (@Title,@RequestedBy,@Amount,@ReqStatus,@CreatedDate)
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN
    END CATCH
END

EXEC uspCapExRequestCreate @Title = 'Title 6',@RequestedBy = 3,@Amount = 745000

select * from tblCapExRequest
/*****************************************************************************************
 SECTION 24 – DYNAMIC SQL
******************************************************************************************/

-- Q41. Create a stored procedure:
-- Name: sp_GetCapExByColumn
-- Inputs:
-- @ColumnName
-- @Value
-- Use dynamic SQL to filter CapExRequest
-- Use sp_executesql

GO
CREATE OR ALTER PROCEDURE uspCapExByColumnGet
(
    @ColumnName SYSNAME,        -- column name
    @Value      NVARCHAR(200)   -- filter value
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    -- Build dynamic SQL safely
    SET @SQL = N'
        SELECT *
        FROM tblCapExRequest
        WHERE ' + QUOTENAME(@ColumnName) + N' = @FilterValue';

    -- Execute dynamic SQL
    EXEC sp_executesql
        @SQL,
        N'@FilterValue NVARCHAR(200)',
        @FilterValue = @Value;
END;

exec uspCapExByColumnGet 'Title','Title1'


-- Q42. Create a dynamic SQL procedure to:
-- Sort CapEx requests by any column name passed as parameter
GO
CREATE OR ALTER PROC uspCapExRequestSort
    (@ColumnName SYSNAME)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @sql NVARCHAR(MAX)

    SET @sql = 
    N'SELECT * FROM tblCapExRequest
    ORDER BY ' + QUOTENAME(@ColumnName) 

    EXEC sp_executesql @sql
END

EXEC uspCapExRequestSort 'Amount'

/*****************************************************************************************
 SECTION 25 – COMPLEX REAL-WORLD SCENARIOS
******************************************************************************************/

-- Q43. Write a query to identify:
-- CapEx requests where approval is pending more than 7 days
SELECT * FROM tblCapExRequest
WHERE ReqStatus = 'Pending' AND DATEDIFF(DAY,CreatedDate,GETDATE()) > 5


-- Q44. Write a query to detect:
-- Divisions exceeding 80% of their allocated budget

SELECT * FROM tblBudget
WHERE (TotalBudget * 0.8) < UtilizedAmount



-- Q45. Write a query to find:
-- Requests that were approved but do not have asset records

SELECT *
FROM tblCapExRequest
WHERE ReqStatus = 'Approved'
AND RequestID NOT IN (SELECT RequestID FROM tblAsset WHERE RequestID IS NOT NULL);


/*****************************************************************************************
 SECTION 26 – PERFORMANCE & OPTIMIZATION
******************************************************************************************/

-- Q46. Explain (in comments):
-- a) When to use CTE vs Temp Table

-- CTE (Common Table Expression):
-- 1. Use CTEs for **readable, recursive, or one-time queries**.
-- 2. Good for breaking complex queries into logical steps.
-- 3. Exists only during the execution of a single query.
-- 4. Cannot have indexes (except through query hints in some cases).

-- Temp Table (#TempTable):
-- 1. Use temp tables when **you need to store intermediate results** for multiple queries.
-- 2. Can create indexes, constraints, and statistics.
-- 3. Exists in TempDB, lasts for the session or until dropped.
-- 4. Useful for large data processing or multiple-step ETL processes.

-- b) Why cursors are discouraged
-- 1. Cursors process rows **one at a time** (row-by-row / RBAR: "row by agonizing row").
-- 2. This is much slower than set-based operations in SQL.
-- 3. They consume **more memory** and can lock resources longer.
-- 4. Only use cursors when **row-by-row logic is unavoidable** (rare).

-- c) When dynamic SQL is necessary
-- 1. When **table or column names are not known until runtime**.
-- 2. When building **pivot queries or search filters dynamically**.
-- 3. When implementing **optional WHERE clauses** based on input parameters.
-- 4. Sometimes used for security bypassing or modularity, but must handle SQL Injection carefully.


/*****************************************************************************************
 SECTION 27 – BONUS CHALLENGE (OPTIONAL)
******************************************************************************************/

-- Q47. Design a solution (SQL only):
-- Automatically escalate CapEx requests
-- If pending approval exceeds 5 days
-- (Explain logic in comments)
GO
SELECT c.RequestID
FROM tblCapExRequest c
WHERE c.ReqStatus = 'Pending'
AND EXISTS (
    SELECT 1
    FROM tblApprovalHistory a
    WHERE a.RequestID = c.RequestID
      AND a.ApprovalAction = 'PENDING'
      AND c.CreatedDate > DATEADD(DAY, -5, GETDATE())
);


GO

select * from tblCapExRequest
/******************************************** END OF ADVANCED TEST *************************/
GO


DECLARE @thres DECIMAL(18,2) = 25000.00;
DECLARE @sql NVARCHAR(MAX); 
DECLARE @Params NVARCHAR(50) = N'@thres DECIMAL(18,2)';
SET @sql = N'SELECT * FROM tblCapExRequest WHERE Amount > @thres'

EXEC sp_executesql @sql,@Params,@thres = @thres

