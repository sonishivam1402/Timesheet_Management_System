USE [UCITMSDev]
GO

/****** Object:  UserDefinedTableType [dbo].[TeamMemberType]    Script Date: 14-10-2024 14:52:13 ******/
CREATE TYPE [dbo].[TeamMemberType] AS TABLE(
	[UserID] [int] NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[MaxWeeklyHours] [int] NULL
)
GO


