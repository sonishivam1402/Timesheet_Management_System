USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanEditTimesheetLineId]    Script Date: 17-12-2024 23:19:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE function [dbo].[fnCanEditTimesheetLineId](@TimesheetId int,@LineId int)
returns bit
as
Begin
declare @hasAccess bit=0
if exists (
			
			select 1 from dbo.TimesheetLines T with (NoLock) where T.TimesheetId=@TimesheetId and T.LineID=@LineId
			
			)
	begin
		Set @hasAccess=1
	end
return @hasAccess
end
 

GO

