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
DECLARE @b DATETIME2 = GETDATE()

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

SELECT * FROM tblBudget

-- Q4. Scenario:
-- A column storing phone numbers is defined as INT.
-- What issues can occur?
-- How would you fix it safely?
/*****************************************************************************************
 SECTION 3 – TRANSACTIONS & ACID
******************************************************************************************/

-- Q5. Explain ACID properties with real examples (comments).



-- Q6. Write SQL to demonstrate:
-- a) BEGIN TRAN
-- b) COMMIT
-- c) ROLLBACK
-- Explain a real failure scenario where rollback is required.



/*****************************************************************************************
 SECTION 4 – ISOLATION LEVELS & LOCKING
******************************************************************************************/

-- Q7. List all isolation levels in SQL Server (comments).



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



-- Q11. Scenario:
-- A table has a clustered index on CreatedDate.
-- Queries filter mostly by RequestID.
-- What is wrong? How would you fix it?



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



/*****************************************************************************************
 SECTION 11 – BACKUP & RECOVER

