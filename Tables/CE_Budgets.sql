Create table CE_Budgets(
	BudgetID int primary key,
	CompanyID int foreign key references CE_Companies(CompanyID),
	YearOfBudget int,
	AllocatedAmount Decimal(18,2),
	SpentAmount Decimal(18,2))