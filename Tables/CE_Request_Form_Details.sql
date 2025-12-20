Create table CE_Request_Form_Details(
	RequestID int primary key,
	CompanyID int Foreign key references CE_Companies(CompanyID),
	RequestDate Date,
	Amount decimal(18,2),
	Descriptions varchar(255),
	Request_Status varchar(20),
	AssetType varchar(50))