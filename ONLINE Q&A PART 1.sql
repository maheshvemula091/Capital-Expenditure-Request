/*****************************************************************************************
 SECTION 39 – FREQUENT INTERVIEW QUICK-FIRE QUESTIONS
******************************************************************************************/

-- Q71. Difference (Explain in comments):
-- a) DELETE vs TRUNCATE vs DROP
/*
| Feature      | DELETE                          | TRUNCATE                        | DROP                            |
| ------------ | ------------------------------- | ------------------------------- | ------------------------------- |
| Type         | DML (Data Manipulation)         | DDL (Data Definition)           | DDL                             |
| Scope        | Specific rows (WHERE) or all    | All rows (table structure kept) | Entire table (structure + data) |
| Speed        | Slowest (row-by-row, logs each) | Fast (de-allocates pages)       | Fastest (drops metadata)        |
| WHERE clause | ✅ Yes                          | ❌ No                          | ❌ No                           |
| Rollback     | ✅ Yes (full logging)           | ✅ Yes (minimal logging)       | ❌ No (auto-commit)             |
| Triggers     | ✅ Fires DELETE triggers        | ❌ No triggers                 | ❌ No triggers                  |
| Identity     | Preserves current value         | Resets to seed                  | Table gone                      |
| Foreign Keys | ✅ Respects constraints         | ✅ Respects constraints        | ❌ Can orphan children          |
| Locks        | Row locks                       | Table lock                      | Schema lock                     |
| Permissions  | DELETE permission               | ALTER permission                | ALTER + CONTROL                 |
*/
-- b) WHERE vs HAVING
/*
| Feature     | WHERE                           | HAVING                                      |
| ----------- | ------------------------------- | ------------------------------------------- |
| Timing      | Before GROUP BY (raw rows)      | After GROUP BY (aggregated)         ​        |
| Aggregates  | Cannot use SUM(), COUNT(), etc. | Can use aggregate functions			    ​  |
| Scope       | Individual row conditions       | Group-level conditions                      |
| Performance | Faster (filters early)          | Slower (filters after aggregation)		  |
*/

-- c) UNION vs UNION ALL
/*
| Feature     | UNION                                                                | UNION ALL                                 |
| ----------- | -------------------------------------------------------------------- | ----------------------------------------- |
| Duplicates  | Removes all duplicate rows			                                 | Keeps all duplicates                      |
| Performance | Slower (sorts/hashes to remove duplicates)			 ​                | Faster (simple concatenation)             |
| Result size | Smaller (unique rows only)				​                             | Larger (all rows)			             |
| Sorting     | Implicit sort (order not guaranteed without ORDER BY)			   ​  | No sorting				                 |
*/

-- Q72. Write queries to:
-- a) Get second highest CapEx amount
-- b) Get Nth highest CapEx amount using parameter
GO
CREATE OR ALTER FUNCTION Fn_CapExAmountRankGet(@Rn INT)
RETURNS TABLE
AS
	RETURN(
	WITH CapExCTE
	AS
		(SELECT *,
		DENSE_RANK() OVER(ORDER BY Amount DESC) as rn
		FROM tblCapExRequest)
	SELECT * FROM CapExCTE
	WHERE rn = @Rn)

GO
SELECT * FROM Fn_CapExAmountRankGet(3)
-- Q73. Find duplicate CapEx requests by Title
-- Show count > 1
GO
WITH CapExTitleCte
AS
	(SELECT *,
	ROW_NUMBER() OVER(PARTITION BY Title ORDER BY RequestID) as rn
	FROM tblCapExRequest)
SELECT * FROM CapExTitleCte
WHERE rn >1

/*****************************************************************************************
 SECTION 40 – SUBQUERIES & CORRELATED SUBQUERIES
******************************************************************************************/

-- Q74. Write a subquery:
-- Fetch CapEx requests where Amount >
-- Average CapEx amount of all requests

SELECT * FROM tblCapExRequest
WHERE Amount > (SELECT AVG(Amount) FROM tblCapExRequest)

-- Q75. Write a correlated subquery:
-- Fetch CapEx requests where Amount >
-- Average amount of that division


SELECT c.*
FROM tblCapExRequest c
JOIN tblUsers u
    ON c.RequestedBy = u.UserID
WHERE c.Amount >
(
    SELECT AVG(c2.Amount)
    FROM tblCapExRequest c2
    JOIN tblUsers u2
        ON c2.RequestedBy = u2.UserID
    WHERE u2.DivisionID = u.DivisionID
);



/*****************************************************************************************
 SECTION 41 – EXISTS vs IN
******************************************************************************************/

-- Q76. Write two queries:
-- a) Using IN
-- b) Using EXISTS
-- To find requests having approvals
-- Explain performance difference in comments
GO
SELECT * FROM tblCapExRequest
WHERE RequestID IN
	(SELECT DISTINCT RequestID FROM tblApprovalHistory)

SELECT * FROM tblCapExRequest c
WHERE EXISTS 
	(SELECT 1 FROM tblApprovalHistory a 
	WHERE a.RequestID = c.RequestID)



/*****************************************************************************************
 SECTION 42 – IDENTITY, SEQUENCE & KEYS
******************************************************************************************/

-- Q77. Explain in comments:
-- a) IDENTITY vs SEQUENCE
-- b) When to use each

/*
| Feature        | IDENTITY                              | SEQUENCE                                                       |
| -------------- | ------------------------------------- | -------------------------------------------------------------- |
| Scope          | Tied to one table column              | Shareable across multiple tables sqlshack​                      |
| Creation       | CREATE TABLE T (Id INT IDENTITY(1,1)) | CREATE SEQUENCE Seq START WITH 1 INCREMENT BY 1                |
| Usage          | Auto-generates on INSERT              | NEXT VALUE FOR Seq in any query                                |
| Max value      | Limited by column datatype (INT max)  | MAXVALUE option configurable                                   |
| Cycle          | No restart option                     | CYCLE to restart at MIN/MAX                                    |
| Get next value | Requires INSERT                       | SELECT NEXT VALUE FOR Seq (no table needed)                    |
| Transaction    | Scoped to transaction                 | Visible across transactions                                    |
*/


-- Q78. Create a SEQUENCE:
-- Generate unique request reference numbers



/*****************************************************************************************
 SECTION 43 – TRANSACTION ISOLATION & LOCKING
******************************************************************************************/

-- Q79. Explain in comments:
-- All transaction isolation levels in SQL Server
-- Which one prevents dirty reads?



-- Q80. Simulate (write code):
-- Read Uncommitted vs Read Committed scenario
-- (Use comments if simulation not possible)



/*****************************************************************************************
 SECTION 44 – INDEXING FREQUENT QUESTIONS
******************************************************************************************/

-- Q81. Explain in comments:
-- a) Clustered vs Non-Clustered index
-- b) Covering index
-- c) Included columns



-- Q82. Write a query to:
-- Identify missing indexes
-- (Using DMV)



/*****************************************************************************************
 SECTION 45 – TEMP OBJECTS & MEMORY
******************************************************************************************/

-- Q83. Explain in comments:
-- a) #Temp table vs ##Global temp table
-- b) Table variable vs Temp table



-- Q84. Write a query:
-- Use temp table to store intermediate results
-- Then join with main table



/*****************************************************************************************
 SECTION 46 – NULLS & EDGE CASES
******************************************************************************************/

-- Q85. Write queries to:
-- a) Handle NULLs in arithmetic calculations
-- b) Compare NULL values correctly



/*****************************************************************************************
 SECTION 47 – STRING & DATA CONVERSION
******************************************************************************************/

-- Q86. Write queries using:
-- CAST
-- CONVERT
-- FORMAT (date & currency)



-- Q87. Extract:
-- Domain name from Email column in Users table

SELECT SUBSTRING('MAHESH@GMAIL.COM',CHARINDEX('@','MAHESH@GMAIL.COM')+1,LEN('MAHESH@GMAIL.COM'))

/*****************************************************************************************
 SECTION 48 – REAL-TIME PROBLEM SOLVING
******************************************************************************************/

-- Q88. Problem:
-- CapEx approval status is incorrect due to partial failure
-- Write SQL steps to safely fix data using transaction



-- Q89. Problem:
-- Duplicate approvals exist for same level
-- Write query to identify and remove duplicates safely



/*****************************************************************************************
 SECTION 49 – PERFORMANCE TROUBLESHOOTING
******************************************************************************************/

-- Q90. Explain in comments:
-- How parameter sniffing occurs
-- How to fix it



-- Q91. Explain in comments:
-- Why SELECT * is bad in production



/*****************************************************************************************
 SECTION 50 – FINAL INTERVIEW THINKING
******************************************************************************************/

-- Q92. Explain in comments:
-- How you would design auditing for regulatory compliance



-- Q93. Explain in comments:
-- How you would archive old CapEx data



-- Q94. Explain in comments:
-- How SQL supports Nintex / workflow tools



-- Q95. Explain in comments:
-- One real performance issue you faced
-- And how you resolved it



/************************************* END OF INTERVIEW PRACTICE SET *********************/
