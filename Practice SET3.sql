CREATE DATABASE CapEx5

USE CapEx5
GO

/* =====================================================
   SQL PRACTICE QUESTIONS – WRITE YOUR ANSWERS BELOW
   ===================================================== */


CREATE TABLE tblDepartment(
	DeptID INT PRIMARY KEY IDENTITY(1,1),
	DeptName NVARCHAR(200))

CREATE TABLE tblEmployee(
	EmpID INT PRIMARY KEY IDENTITY(1,1),
	EmpName NVARCHAR(200),
	Salary DECIMAL(18,2),
	DeptID INT,
	HireDate DATETIME2)


INSERT INTO tblDepartment(DeptName)
VALUES
('IT'),
('HR'),
('Finance');

INSERT INTO tblEmployee(EmpName,Salary,DeptID,HireDate)
VALUES
('Ravi', 50000, 1, '2021-01-10'),
('Anil', 60000, 1, '2020-03-15'),
('Sita', 45000, 2, '2022-07-20'),
('Meena', 70000, 1, '2019-11-25'),
('John', 40000, 3, '2021-05-05'),
('David', 40000, 3, '2021-05-05');

INSERT INTO tblDepartment(DeptName)
VALUES
('CE')
--------------------------------------------------------
-- BASIC SELECT & FILTERING
--------------------------------------------------------

-- 1. Display all employees.

SELECT * FROM tblEmployee

-- 2. Display employee name and salary only.

SELECT EmpName,Salary FROM tblEmployee

-- 3. Find employees whose salary is greater than 50,000.

SELECT * FROM tblEmployee
WHERE Salary > 50000

-- 4. List employees who joined after '2021-01-01'.

SELECT * FROM tblEmployee
WHERE HireDate > '2021-01-01'

-- 5. Display employees whose name starts with 'R'.

Select * from tblEmployee
where EmpName like '[R]%'

--------------------------------------------------------
-- JOINS
--------------------------------------------------------

-- 6. Display employee name and department name.

SELECT e.EmpName,d.DeptName from tblEmployee e
JOIN tblDepartment d ON e.DeptID = d.DeptID

-- 7. Find all employees working in IT department.

SELECT e.* from tblEmployee e
JOIN tblDepartment d ON e.DeptID = d.DeptID
WHERE d.DeptName = 'IT'

-- 8. Display employees who do not belong to any department.

SELECT e.EmpName,d.DeptName from tblEmployee e
LEFT JOIN tblDepartment d ON e.DeptID = d.DeptID
WHERE d.DeptID IS NULL

-- 9. Display all departments even if no employees exist.

SELECT e.EmpName,d.DeptName from tblEmployee e
RIGHT JOIN tblDepartment d ON e.DeptID = d.DeptID


-- 10. Find total number of employees in each department.

SELECT DeptID,Count(*) from tblEmployee
Group by DeptID

--------------------------------------------------------
-- AGGREGATES & GROUP BY
--------------------------------------------------------

-- 11. Find average salary of all employees.

SELECT AVG(Salary) from tblEmployee

-- 12. Find average salary department-wise.

SELECT DeptID,AVG(Salary) from tblEmployee
group by DeptID

-- 13. Display departments having more than 2 employees.

Select DeptID,Count(*) from tblEmployee
group by DeptID
having Count(*) > 2

-- 14. Find total salary paid per department.

SELECT DeptID,SUM(Salary) from tblEmployee
group by DeptID


-- 15. Display departments where total salary is greater than 100000.

SELECT DeptID,SUM(Salary) from tblEmployee
group by DeptID
having sum(Salary) > 50000

--------------------------------------------------------
-- SUBQUERIES
--------------------------------------------------------

-- 16. Find employees earning more than average salary.

SELECT * from tblEmployee
where Salary > (SELECT AVG(Salary) from tblEmployee)

-- 17. Find employees earning the highest salary.

Select * from tblEmployee
where Salary = (SELECT MAX(Salary) FROM tblEmployee)

-- 18. Find second highest salary.

SELECT MAX(Salary) FROM tblEmployee
where Salary < (Select Max(Salary) From tblEmployee)

-- 19. Find employees working in departments present in Departments table.

select * from tblEmployee
where DeptID in (Select DeptID from tblDepartment)

-- 20. Find departments that have at least one employee.

SELECT * FROM tblDepartment d
where exists (SELECT 1 from tblEmployee e
where e.DeptID = d.DeptID)

--------------------------------------------------------
-- WINDOW FUNCTIONS
--------------------------------------------------------

-- 21. Rank employees based on salary (highest first).

WITH RankCTE
AS
(SELECT *,
	RANK() over(ORDER BY Salary DESC) as rn from tblEmployee)
select * from RankCTE

-- 22. Display highest paid employee in each department.

Select Max(Salary),DeptID from tblEmployee
Group by DeptID

Select * from 
(Select *,
	Rank() over (Partition by DeptID Order BY Salary DESC) as Rn from tblEmployee) t
where rn =1 

-- 23. Assign row number to employees ordered by JoinDate.

with RowCTE
AS
(select *,
	ROW_NUMBER() over (ORDER BY HireDate) as rn from tblEmployee)
SELECT * from RowCTE

-- 24. Show employees along with previous employee’s salary.

Select *,
	LAG(Salary) Over (ORDER BY EmpID) as Prev
	from tblEmployee

-- 25. Find top 2 highest salaries per department.

select * from(
	select *,
	DENSE_RANK() over (partition by DeptID Order by Salary) as rn
	from tblEmployee) t
where rn <= 2

--------------------------------------------------------
-- DML & TRANSACTIONS
--------------------------------------------------------

-- 26. Increase salary by 10% for employees in IT department.

Update tblEmployee
set Salary = Salary * 1.1
where DeptID = (Select DeptID from tblDepartment where DeptName = 'IT')

-- 27. Delete employees whose salary is less than 45000 (use transaction).

Begin Tran
	Delete from tblEmployee
	where Salary < 45000
RollBack

-- 28. Demonstrate ROLLBACK after DELETE.

Begin Tran
	Delete from tblEmployee
	where DeptID = 3
RollBack

-- 29. Update employee salary and COMMIT the transaction.
Begin Tran
	Update tblEmployee
	set Salary = Salary+5000
	where DeptID =2
Commit

-- 30. Delete all rows from Employees table without dropping the table.

--------------------------------------------------------
-- VIEWS & FUNCTIONS
--------------------------------------------------------

-- 31. Create a view showing employee name, salary, and department name.
GO
Create view VW_EmpDetails
AS
(Select e.EmpName,e.Salary,d.DeptName from tblEmployee e
Join tblDepartment d 
ON e.DeptID = d.DeptID) 



-- 32. Select data from the created view.

GO
Select * from VW_EmpDetails

-- 33. Create a scalar function to calculate 10% tax on salary.
GO

Create function Fn_Calculate(@Salary Decimal(18,2))
Returns Decimal(18,2)
AS
Begin
	Return @Salary * 0.1
END

-- 34. Use the above function in a SELECT query.
GO
SELECT EmpID,EmpName,Salary,dbo.Fn_Calculate(Salary) as Tax from tblEmployee

-- 35. Create an inline table-valued function to return employees by department.
GO
CREATE FUNCTION Fn_EmployeeByDept(@DeptID INT)
RETURNS TABLE
AS
	RETURN(SELECT * from tblEmployee
	where DeptID = @DeptID)
GO
Select * from Fn_EmployeeByDept(1)

--------------------------------------------------------
-- PERFORMANCE & REAL-TIME SCENARIOS
--------------------------------------------------------

-- 36. Enable actual execution plan and run a SELECT query.

Select * from tblEmployee

-- 37. Find duplicate salaries from Employees table.
go
select Salary,Count(*) from tblEmployee
Group by Salary
Having Count(*) >1


-- 38. Find employees hired on the same date.

select HireDate,Count(*) from tblEmployee
Group by HireDate
Having Count(*) >1

-- 39. Write a query using EXISTS.

select * from tblDepartment d
where exists (select 1 from tblEmployee e where e.DeptID = d.DeptID)

-- 40. Write a query using NOT EXISTS.

select * from tblDepartment d
where not exists (select 1 from tblEmployee e where e.DeptID = d.DeptID)

--------------------------------------------------------
-- INTERVIEW SCENARIO QUESTIONS (WRITE SQL WHERE POSSIBLE)
--------------------------------------------------------

-- 41. Database is in use. Write a query to find who is using it.

SELECT session_id, login_name, host_name, program_name
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('CapEx5');

-- 42. Database is in use. Write SQL to drop the database safely.
GO

USE MASTER;
ALTER DATABASE CapEx5
SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
-- 43. Write SQL to find long-running queries.

SELECT * FROM sys.dm_exec_requests
WHERE status = 'running';

-- 44. Write SQL to check open transactions in a database.

DBCC OPENTRAN

-- 45. Demonstrate DELETE vs TRUNCATE with transaction and rollback.

BEGIN TRAN;
DELETE FROM tblEmployee;
ROLLBACK;

BEGIN TRAN;
TRUNCATE TABLE tblEmployee;
ROLLBACK;


select *,
	rank() over(order by Salary ASC) as ran,
	DENSE_RANK() over(order by Salary ASC) as dran,
	ROW_NUMBER() over(Order by Salary ASC) as rn
	from tblEmployee