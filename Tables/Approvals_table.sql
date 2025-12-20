USE [CE_Request]
GO

/****** Object:  Table [dbo].[CE_Approvals]    Script Date: 20-12-2025 15:37:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CE_Approvals](
	[ApprovalID] [int] NOT NULL,
	[RequestID] [int] NULL,
	[ApproverID] [int] NULL,
	[ApprovalDate] [date] NULL,
	[Notes] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ApprovalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CE_Approvals]  WITH NOCHECK ADD FOREIGN KEY([RequestID])
REFERENCES [dbo].[CE_RequestForm_Details] ([RequestID])
GO

