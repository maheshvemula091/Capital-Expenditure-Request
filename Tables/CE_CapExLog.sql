create table CE_CapExLog(
	LogInID int identity(1,1) primary key,
	RequestID int foreign key references CE_Request_Form_Details(RequestID),
	LogAction varchar(50),
	ChangeDate Datetime,
	Details varchar(255)) 