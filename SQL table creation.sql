Create table CE_Companies(CompanyID int PRIMARY KEY,
						  Name nvarchar(100),
						  Industry nvarchar(50),
						  Location nvarchar(50),
						  AnnualBudget Decimal(18,2))


Create table CE_RequestForm_Details(RequestID int PRIMARY KEY,
									CompanyID int foreign key references CE_Companies(CompanyID),
									RequestDate Date,
									Amount Decimal(18,2),
									Description Nvarchar(255),
									Status nvarchar(20),
									AssetType nvarchar(50))

Create table CE_Assets(AssetID int Primary key,
					   RequestID int foreign key references CE_RequestForm_Details(RequestID),
					   Name nvarchar(100),
					   Cost Decimal(18,2),
					   DepreciationRate Decimal(5,4),
					   PurchaseDate Date)

Create table CE_Approvals(ApprovalID int Primary key,
						  RequestID int foreign key references CE_RequestForm_Details(RequestID),
						  ApproverID int,
						  ApprovalDate date,
						  Notes Nvarchar(255))

Create table CE_Budgets(BudgetID int primary key,
					    CompanyID int foreign key references CE_COmpanies(CompanyID),
						Year int,
						AllocatedAmount decimal(18,2),
						SpentAmount decimal(18,2))

Create table CE_CAPExLog(LogID int IDENTITY(1,1) primary key,
						 RequestID int,
						 Action nvarchar(50),
						 ChangeDate DateTime,
						 Details Nvarchar(255))


-- Mirror CE_Request_Form_Details for ETL

Create Table CE_Staging_Imports(
	RequestID INT,
    CompanyID INT,
    RequestDate DATE,
    Amount DECIMAL(18,2),
    Description VARCHAR(255),
    Status VARCHAR(20),
    AssetType VARCHAR(50))


-- Create an error log table for ETL

CREATE TABLE ImportErrors (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    ImportDate DATETIME,
    ErrorMessage VARCHAR(500),
    InvalidData VARCHAR(500)
)




