Create table CE_Approvals(
	ApprovalID int primary key,
	RequestID int foreign key references CE_Request_Form_Details(RequestID),
	ApproverID int,
	ApprovalDate date,
	Notes varchar(255))