USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanEditTimesheet]    Script Date: 08-12-2024 02:18:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE function [dbo].[fnCanEditTimesheet](@TimesheetId int,@CurrentUserId int)
returns bit
as
Begin
declare @hasAccess bit=0
if exists (
			select 1 from TimesheetHdr T with (noLock) where T.TimesheetId=@TimesheetId and T.UserId=@CurrentUserId
			and T.Status in (1,4)
			)
	begin
		Set @hasAccess=1
	end
return @hasAccess
end
 

GO

