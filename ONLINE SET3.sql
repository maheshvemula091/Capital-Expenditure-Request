/*****************************************************************************************
 SECTION 28 – DATA INTEGRITY, CONSTRAINTS & VALIDATIONS
******************************************************************************************/

-- Q48. Add a CHECK constraint to CapExRequest:
-- Ensure Status can be only:
-- ('Draft', 'Submitted', 'Approved', 'Rejected')



-- Q49. Add a UNIQUE constraint:
-- Prevent duplicate CapEx titles per division



-- Q50. Add ON DELETE / ON UPDATE rules:
-- Prevent deletion of Users if CapEx requests exist



/*****************************************************************************************
 SECTION 29 – TEMP TABLES & TABLE VARIABLES
******************************************************************************************/

-- Q51. Use a TEMP TABLE:
-- Store all Approved CapEx requests
-- Then query total amount per division



-- Q52. Rewrite Q51 using a TABLE VARIABLE
-- Explain difference in comments



/*****************************************************************************************
 SECTION 30 – DATE & TIME LOGIC
******************************************************************************************/

-- Q53. Write queries to:
-- a) Get CapEx requests created in current month
-- b) Get requests from previous fiscal year
-- c) Calculate number of days request stayed in Pending status



/*****************************************************************************************
 SECTION 31 – NULL HANDLING & DATA CLEANING
******************************************************************************************/

-- Q54. Use ISNULL / COALESCE:
-- Replace NULL UtilizedAmount with 0
-- Show impact in budget calculations



-- Q55. Identify:
-- CapEx requests with missing approval records



/*****************************************************************************************
 SECTION 32 – MERGE STATEMENT (UPSERT)
******************************************************************************************/

-- Q56. Write a MERGE statement:
-- Source: New budget data
-- Target: Budget table
-- Perform INSERT or UPDATE accordingly



/*****************************************************************************************
 SECTION 33 – JSON & XML (BASIC)
******************************************************************************************/

-- Q57. Store CapEx request metadata as JSON
-- Extract values using JSON_VALUE()



-- Q58. Convert CapEx request data to XML format



/*****************************************************************************************
 SECTION 34 – ERROR SCENARIOS & DEBUGGING
******************************************************************************************/

-- Q59. Simulate an error inside a transaction
-- Show how TRY...CATCH captures:
-- ERROR_MESSAGE()
-- ERROR_NUMBER()



-- Q60. Explain in comments:
-- Difference between THROW and RAISERROR



/*****************************************************************************************
 SECTION 35 – SECURITY & BEST PRACTICES
******************************************************************************************/

-- Q61. Create a SQL ROLE:
-- FinanceRole
-- Grant SELECT on Budget and CapExRequest



-- Q62. Explain in comments:
-- Why dynamic SQL can cause SQL Injection
-- How sp_executesql prevents it



/*****************************************************************************************
 SECTION 36 – ADVANCED QUERY CHALLENGES
******************************************************************************************/

-- Q63. Write a query to:
-- Find CapEx requests where Amount > Average Amount of that division



-- Q64. Identify:
-- Divisions with zero CapEx requests in last 6 months



-- Q65. Write a query to:
-- Detect duplicate asset values across different requests



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
