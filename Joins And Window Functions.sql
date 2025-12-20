select Top(20) * from [dbo].[CE_RequestForm_Details]
select * from [dbo].[CE_Companies]


select count(r.RequestID),c.Company_Name,sum(r.Amount),r.Status 
from CE_RequestForm_Details r 
Join CE_Companies c on r.CompanyID  = c.CompanyID
where r.Status = 'Approved'

select count(r.RequestID),c.Company_Name,sum(r.Amount),Sum(c.AnnualBudget)
from CE_RequestForm_Details r 
join CE_Companies c
on r.CompanyID = c.CompanyID
Group BY c.Company_Name
order by sum(r.Amount)




-- Use HAVING in a grouped version if needed
-- HAVING is for aggregate functions (SUM, COUNT, etc.).
-- ROW_NUMBER() is a window function, so HAVING cannot filter on it directly. That’s why we always wrap it in a CTE or subquery first.

SELECT Industry, RequestID, Amount,
ROW_NUMBER() OVER (PARTITION BY c.Industry ORDER BY r.Amount DESC) AS Rank
FROM CE_RequestForm_Details r
JOIN CE_Companies c ON r.CompanyID = c.CompanyID
WHERE Amount > 100000;  


SELECT Industry, RequestID, Amount, Rank
FROM (
    SELECT 
        c.Industry,
        r.RequestID,
        r.Amount,
        ROW_NUMBER() OVER (PARTITION BY c.Industry ORDER BY r.Amount DESC) AS Rank
    FROM CE_RequestForm_Details r
    JOIN CE_Companies c ON r.CompanyID = c.CompanyID
    WHERE Amount > 100000
) ranked
WHERE Rank <= 5;



SELECT c.Industry,c.Company_Name, SUM(r.Amount) AS TotalSpend,YEAR(r.RequestDate) AS Year,
LAG(SUM(r.Amount)) OVER (PARTITION BY c.Company_Name ORDER BY YEAR(r.RequestDate)) AS PrevYearSpend
FROM CE_RequestForm_Details r
JOIN CE_Companies c ON r.CompanyID = c.CompanyID
GROUP BY c.Company_Name, YEAR(r.RequestDate),c.Industry
HAVING SUM(r.Amount) > 1000000;



SELECT 
    r.RequestID,
    r.RequestDate,
    r.Amount,
    r.Description,
    c.Company_Name,
    c.AnnualBudget,

    -- 1. Total requested per company (same value on every row of the company)
    SUM(r.Amount) OVER (PARTITION BY c.Company_Name)                    AS Company_Total_Requested,

    -- 2. Average request amount in this company
    ROUND(AVG(r.Amount) OVER (PARTITION BY c.Company_Name), 2)          AS Company_Avg_Request,

    -- 3. This request as % of company annual budget
    ROUND(r.Amount * 100.0 / c.AnnualBudget, 2)                         AS Percent_Of_Annual_Budget,

    -- 4. Rank of this request inside its company (1 = most expensive)
    RANK() OVER (PARTITION BY c.Company_Name ORDER BY r.Amount DESC)    AS Rank_In_Company,

    -- 5. Running total (cumulative) of amounts for this company, ordered by date
    SUM(r.Amount) OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate) 
                  AS Running_Total_By_Date,

    -- 6. Row number (just a sequential number per company)
    ROW_NUMBER() OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate DESC) 
                  AS Latest_First
FROM CE_RequestForm_Details r
JOIN CE_Companies c ON r.CompanyID = c.CompanyID
ORDER BY c.Company_Name,r.Amount ASC;



SELECT 
    c.Company_Name,
    r.RequestDate,
    r.Amount,
    
    -- Amount of the previous request from the same company
    LAG(r.Amount) OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate) 
        AS Previous_Request_Amount,
    
    -- Difference from previous request
    r.Amount - LAG(r.Amount) OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate) 
        AS Change_From_Previous,
    
    -- % growth from previous request
    ROUND(
        100.0 * (r.Amount - LAG(r.Amount) OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate)) 
        / NULLIF(LAG(r.Amount) OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate), 0)
    , 2) AS Percent_Change_From_Previous,

    -- Next request amount (LEAD)
    LEAD(r.Amount) OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate) 
        AS Next_Request_Amount

FROM CE_RequestForm_Details r
JOIN CE_Companies c ON r.CompanyID = c.CompanyID
ORDER BY c.Company_Name, r.RequestDate;




SELECT DISTINCT
    c.Company_Name,
    
    FIRST_VALUE(r.Amount)     OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate 
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 
        AS First_Ever_Request_Amount,
        
    FIRST_VALUE(r.RequestDate) OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate) 
        AS First_Request_Date,
        -- default frame = RANGE UNBOUNDED PRECEDING AND CURRENT ROW
        
    LAST_VALUE(r.Amount)      OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate 
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 
        AS Most_Recent_Request_Amount,
        
    LAST_VALUE(r.RequestDate) OVER (PARTITION BY c.Company_Name ORDER BY r.RequestDate 
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 
        AS Most_Recent_Request_Date
FROM CE_RequestForm_Details r
JOIN CE_Companies c ON r.CompanyID = c.CompanyID;




EXEC sp_rename 'CE_Companies.Name', 'Company_Name', 'COLUMN';

select * from CE_RequestForm_Details 

