/*****************************************************************************************
 SECTION 51 – COMPLEX PRODUCTION SCENARIOS
******************************************************************************************/

-- Q96. DEADLOCK SCENARIO
-- Two users are approving CapEx requests simultaneously and deadlocks occur.
-- a) Explain how deadlocks happen
-- b) Write SQL best practices to prevent them
-- c) How would you detect deadlocks in SQL Server?



-- Q97. CONCURRENCY ISSUE
-- Multiple approvers update the same CapExRequest at the same time.
-- a) What problems can occur?
-- b) How would you solve this using transactions or isolation levels?



-- Q98. DATA CONSISTENCY FAILURE
-- Budget.UtilizedAmount does not match total approved CapEx.
-- a) Write a query to identify mismatch
-- b) Write SQL to fix it safely



/*****************************************************************************************
 SECTION 52 – PERFORMANCE & SCALABILITY SCENARIOS
******************************************************************************************/

-- Q99. SLOW REPORT QUERY
-- A report joining CapExRequest, Users, ApprovalHistory takes 30 seconds.
-- a) What steps would you take to troubleshoot?
-- b) Which indexes would you add?



-- Q100. LARGE DATA HANDLING
-- CapExRequest table grows to 50 million rows.
-- a) What schema changes would you suggest?
-- b) How would partitioning help?



/*****************************************************************************************
 SECTION 53 – DATA MIGRATION & DEPLOYMENT
******************************************************************************************/

-- Q101. DATA MIGRATION
-- Migrate CapEx data from legacy system to CapEx2.
-- a) How would you validate migrated data?
-- b) What SQL queries would you use for reconciliation?



-- Q102. ZERO-DOWNTIME DEPLOYMENT
-- You need to add a NOT NULL column to CapExRequest in production.
-- a) What is the safe approach?
-- b) Why is it important?



/*****************************************************************************************
 SECTION 54 – SECURITY & COMPLIANCE
******************************************************************************************/

-- Q103. ROW-LEVEL SECURITY
-- Finance users should see all divisions.
-- Other users should see only their division.
-- Explain how you would implement this in SQL Server.



-- Q104. AUDIT TRAIL FAILURE
-- Audit logs are missing for some updates.
-- a) How would you detect gaps?
-- b) How would you redesign auditing?



/*****************************************************************************************
 SECTION 55 – DATA QUALITY & VALIDATION
******************************************************************************************/

-- Q105. INVALID DATA ENTRY
-- Negative CapEx amounts exist in production.
-- a) Write a query to detect them
-- b) Write SQL to prevent future issues



-- Q106. DUPLICATE WORKFLOWS
-- Same CapEx request entered twice by mistake.
-- a) How would you detect duplicates?
-- b) How would you prevent this?



/*****************************************************************************************
 SECTION 56 – ADVANCED SQL THINKING
******************************************************************************************/

-- Q107. CONDITIONAL AGGREGATION
-- Write a query showing:
-- Total Approved Amount
-- Total Pending Amount
-- Total Rejected Amount
-- Per division (single query)



-- Q108. GAP & ISLANDS PROBLEM
-- Identify gaps in approval dates per request
-- (Hint: window functions)



/*****************************************************************************************
 SECTION 57 – RECOVERY & FAILURE HANDLING
******************************************************************************************/

-- Q109. PARTIAL FAILURE
-- CapEx approved but asset creation failed.
-- a) How would you detect such records?
-- b) How would you recover data safely?



-- Q110. ACCIDENTAL DATA DELETE
-- Budget table was accidentally truncated.
-- a) What immediate steps would you take?
-- b) How would you restore data?



/*****************************************************************************************
 SECTION 58 – FINAL ARCHITECTURAL THINKING
******************************************************************************************/

-- Q111. SYSTEM DESIGN
-- Design an approval workflow that supports:
-- - Parallel approvals
-- - Escalations
-- - Rejections with rework
-- (Explain schema & SQL logic)



-- Q112. SQL LIMITATIONS
-- Which CapEx logic should NOT be in SQL?
-- What should be handled in application/workflow layer?



/************************************* END OF COMPLEX SCENARIOS ***************************/
