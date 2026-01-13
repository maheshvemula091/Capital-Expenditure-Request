/*
Never rename a column directly in production without checking dependencies. 
The safest method is to query via views or update dependent SPs after renaming.
*/

/*****************************************************************************************
 SECTION 1 – SQL SERVER ARCHITECTURE (SCENARIO BASED)
******************************************************************************************/

-- Q1. Explain in comments:
-- a) What happens internally when a SELECT query is executed?
-- b) Role of:
--    - Buffer Cache
--    - Execution Plan
--    - TempDB

/*
Buffer cache, execution plans, and tempdb are core SQL Server components that optimize query performance and manage 
workload during SELECT executions, especially in systems like CapEx reporting.
​

Buffer Cache Role
Buffer cache stores frequently accessed 8KB data pages in memory to minimize disk I/O. 
High hit ratios (>95%) mean queries like budget summaries read from RAM (logical reads) instead of slow disks, 
boosting speed in concurrent Porex workflows.
​

Execution Plan Role
Execution plans are compiled blueprints cached in plan cache, detailing operators (seeks/scans) and costs. 
SQL reuses them for identical queries, skipping reparsing—check via SET STATISTICS XML ON for tuning indexes in approval chains.
​

TempDB Role
Tempdb handles spills from sorts, hashes, CTEs, temp tables, and cursors when memory overflows. 
In GROUP BY reports on large CapEx data, it stores intermediate results; monitor file growth to avoid 
contention via multiple data files.
​*/


-- Q2. Scenario:
-- SQL Server is slow after restart but improves over time.
-- Explain why this happens (comment).

-- Caches are empty → data must be read from disk → queries rebuild memory structures.
-- Over time performance improves as the server “warms up”.

/*****************************************************************************************
 SECTION 2 – DATA TYPES & STORAGE
******************************************************************************************/

-- Q3. Explain in comments:
-- a) VARCHAR vs NVARCHAR

-- “VARCHAR is non-unicode (1 byte) while NVARCHAR is unicode (2 bytes) and mandatory for multilingual data.”
GO
USE CapEx2
DECLARE @a VARCHAR(25) = 'HI👍M'
DECLARE @b NVARCHAR(25) = N'HI👍M'

PRINT @a
PRINT @b


-- b) DATETIME vs DATETIME2

-- “DATETIME2 is more precise, has wider range and should be used in new development instead of DATETIME.”
GO
DECLARE @a DATETIME = GETDATE()
DECLARE @b DATETIME2(5) = GETDATE()

PRINT @a
PRINT @b
-- c) DECIMAL vs FLOAT

-- “FLOAT is approximate and may produce precision errors; DECIMAL is exact and mandatory for financial data.”
GO
DECLARE @i DECIMAL(18,2) = 0.1
DECLARE @f FLOAT = 0.1


PRINT @i
PRINT @f
-- When should each be used?



-- Q4. Scenario:
-- A column storing phone numbers is defined as INT.
-- What issues can occur?
-- How would you fix it safely?
/*
Phone numbers should not be stored as INT because leading zeros are lost, large numbers overflow, and 
formatting/country codes are not supported. 
The safe fix is to store them as VARCHAR and migrate data using a new column with proper validation.
*/

/*****************************************************************************************
 SECTION 3 – TRANSACTIONS & ACID
******************************************************************************************/

-- Q5. Explain ACID properties with real examples (comments).

/*
ATOMICITY
CONSISTENCY
ISOLATION
DURABILITY
*/



-- Q6. Write SQL to demonstrate:
-- a) BEGIN TRAN
-- b) COMMIT
-- c) ROLLBACK
-- Explain a real failure scenario where rollback is required.



/*****************************************************************************************
 SECTION 4 – ISOLATION LEVELS & LOCKING
******************************************************************************************/

-- Q7. List all isolation levels in SQL Server (comments).

/*
| Isolation Level              | SET Command                                                           |
| ---------------------------- | --------------------------------------------------------------------- |
| **READ UNCOMMITTED**         | `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;`                   |
| **READ COMMITTED** (Default) | `SET TRANSACTION ISOLATION LEVEL READ COMMITTED;`                     |
| **REPEATABLE READ**          | `SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;`                    |
| **SERIALIZABLE**             | `SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;`                       |
| **SNAPSHOT**                 | `SET TRANSACTION ISOLATION LEVEL SNAPSHOT;` *(Requires DB option ON)* |
| ---------------------------------- | -------------------------------------------------------- |
| **READ COMMITTED SNAPSHOT (RCSI)** | `ALTER DATABASE YourDB SET READ_COMMITTED_SNAPSHOT ON;`  |
| **ALLOW SNAPSHOT ISOLATION**       | `ALTER DATABASE YourDB SET ALLOW_SNAPSHOT_ISOLATION ON;` |

| Isolation Level  | Dirty Read  | Non-repeatable   | Phantom  |
| ---------------- | ----------  | --------------   | -------  |
| READ UNCOMMITTED | ✅          | ✅              | ✅       |
| READ COMMITTED   | ❌          | ✅              | ✅       |
| REPEATABLE READ  | ❌          | ❌              | ✅       |
| SERIALIZABLE     | ❌          | ❌              | ❌       |
| SNAPSHOT         | ❌          | ❌              | ❌       |
| RCSI             | ❌          | ✅              | ✅       |

*/

-- Q8. Scenario:
-- Dirty reads are happening in reports.
-- a) Which isolation level is causing this?
-- b) How would you fix it?



-- Q9. Explain:
-- a) Blocking
-- b) Deadlock
-- c) Latch
-- (comments)



/*****************************************************************************************
 SECTION 5 – INDEXES (VERY IMPORTANT)
******************************************************************************************/

-- Q10. Explain in comments:
-- a) Clustered index
-- b) Non-clustered index
-- c) Heap table

-- A heap table is a table without a clustered index where data is stored in no particular order and accessed using row identifiers.

-- Q11. Scenario:
-- A table has a clustered index on CreatedDate.
-- Queries filter mostly by RequestID.
-- What is wrong? How would you fix it?
/*
The clustered index is on CreatedDate, but queries mostly filter by RequestID, causing inefficient scans and lookups. 
The fix is to make RequestID the clustered index or at least add a nonclustered index on RequestID based on access patterns.
*/

-- Q12. Explain:
-- a) Included columns
-- b) Covering index
-- With example (comments).



/*****************************************************************************************
 SECTION 6 – QUERY PERFORMANCE
******************************************************************************************/

-- Q13. Scenario:
-- Same query runs fast sometimes and slow sometimes.
-- Explain parameter sniffing (comments).

SELECT *
FROM tblCapExRequest
WHERE RequestID = 100
OPTION (RECOMPILE);

-- Q14. Explain:
-- a) Why SELECT * is bad
-- b) How it impacts performance



-- Q15. Write SQL (comment if not executable):
-- How do you find top 5 slowest queries in SQL Server?



/*****************************************************************************************
 SECTION 7 – TEMPDB (VERY COMMON)
******************************************************************************************/

-- Q16. Explain in comments:
-- a) What is TempDB used for?
-- b) What objects use TempDB?



-- Q17. Scenario:
-- TempDB grows very fast.
-- What could be the reasons?
-- How would you troubleshoot?



/*****************************************************************************************
 SECTION 8 – ERROR HANDLING
******************************************************************************************/

-- Q18. Write a TRY...CATCH example
-- Capture:
-- ERROR_MESSAGE()
-- ERROR_LINE()
-- ERROR_NUMBER()



-- Q19. Explain difference:
-- THROW vs RAISERROR (comments)



/*****************************************************************************************
 SECTION 9 – STORED PROCEDURES & FUNCTIONS
******************************************************************************************/

-- Q20. Explain in comments:
-- a) Stored Procedure vs Function
-- b) When not to use a function



-- Q21. Scenario:
-- A scalar function is used in WHERE clause and query is slow.
-- Why?
-- How to fix it?



/*****************************************************************************************
 SECTION 10 – CURSORS & SET-BASED THINKING
******************************************************************************************/

-- Q22. Explain:
-- a) Why cursors are slow
-- b) When cursors are acceptable (comments)



-- Q23. Convert this logic (conceptually):
-- Row-by-row update → Set-based update
-- Explain approach (comments).

-- Created by GitHub Copilot in SSMS - review carefully before executing
/*
Concept: Convert row-by-row (cursor or loop) updates to a set-based UPDATE.
Example uses existing objects: dbo.tblDivision (DivisionID, IsActive) and dbo.tblBudget
(TotalBudget). The goal: set dbo.tblDivision.IsActive = 0 when the division's total
budget is 0, otherwise 1.

Why set-based?
 - Executes with set semantics in the engine; avoids per-row context switching.
 - Fewer round-trips and less locking/skew from many small transactions.
 - Makes use of aggregations, joins and indexing for better performance.
*/

-- BAD: Row-by-row approach (cursor) — shown for illustration only
-- Comments: Performs a separate aggregation and update per division (slow at scale).
DECLARE @DivID INT;
DECLARE DivCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT DivisionID FROM dbo.tblDivision;

OPEN DivCursor;
FETCH NEXT FROM DivCursor INTO @DivID;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- compute total budget for this division and update IsActive per-row
    DECLARE @SumTotal DECIMAL(18,2);
    SELECT @SumTotal = ISNULL(SUM(TotalBudget),0)
    FROM dbo.tblBudget
    WHERE DivisionID = @DivID;

    UPDATE dbo.tblDivision
    SET IsActive = CASE WHEN @SumTotal = 0 THEN 0 ELSE 1 END
    WHERE DivisionID = @DivID;

    FETCH NEXT FROM DivCursor INTO @DivID;
END;
CLOSE DivCursor;
DEALLOCATE DivCursor;


-- GOOD: Set-based approach — single operation that updates all rows
-- Comments: Aggregate once across dbo.tblBudget, then join to dbo.tblDivision and update
UPDATE d
SET IsActive = CASE WHEN ISNULL(b.SumTotal,0) = 0 THEN 0 ELSE 1 END
FROM dbo.tblDivision AS d
LEFT JOIN (
    SELECT DivisionID, SUM(ISNULL(TotalBudget,0)) AS SumTotal
    FROM dbo.tblBudget
    GROUP BY DivisionID
) AS b 
ON d.DivisionID = b.DivisionID;

-- Notes / Best practices
-- 1) Ensure appropriate indexes exist on join and filter columns (e.g. dbo.tblBudget.DivisionID).
-- 2) Test the update inside a transaction and check rowcounts before committing for large tables.
-- 3) For very large updates consider batching with a WHERE clause on a keyed column to limit touchness.
-- 4) Avoid functions on join predicates and WHERE columns (non-SARGable) for performance.

/*****************************************************************************************
 SECTION 11 – BACKUP & RECOVER

