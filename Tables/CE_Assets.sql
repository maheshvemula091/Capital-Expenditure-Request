create table CE_Assets(
	AssetID int Primary key,
	RequestID int foreign key references CE_Request_Form_Details(RequestID),
	AssetName varchar(100),
	Cost decimal(18,2),
	DepreciationRate decimal(5,4),
	PurchaseDate date)