Bulk Insert CE_Companies
From 'C:\Users\mahes\Documents\SQL\CE_Companies.csv'
With (Fieldterminator = ',',
	  Rowterminator = '\n',
	  Firstrow = 2)


Bulk insert CE_RequestForm_Details
FROM 'C:\Users\mahes\Documents\SQL\CE_Request_Form_Details.csv'
With (FieldTerminator = ',',
	  Rowterminator = '\n',
	  FirstRow = 2)

Bulk insert CE_Assets
FROM 'C:\Users\mahes\Documents\SQL\CE_Assets.csv'
with (Fieldterminator = ',',
      Rowterminator = '\n',
	  FirstRow = 2)

Bulk Insert CE_Budgets
from 'C:\Users\mahes\Documents\SQL\CE_Budgets.csv'
with (Fieldterminator = ',',
      Rowterminator = '\n',
	  FirstRow = 2)

Bulk insert [dbo].[CE_Approvals]
from 'C:\Users\mahes\Documents\SQL\CE_Approvals.csv'
with (Fieldterminator = ',',
      Rowterminator = '\n',
	  FirstRow = 2)


