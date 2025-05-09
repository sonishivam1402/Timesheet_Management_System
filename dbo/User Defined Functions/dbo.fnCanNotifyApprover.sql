USE [UCITMSDev]
GO
/****** Object:  UserDefinedFunction [dbo].[fnCanNotifyApprover]    Script Date: 18-12-2024 15:32:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER function [dbo].[fnCanNotifyApprover](@TimesheetID int,@CurrentUserId int)
returns bit
as
Begin


declare @hasAccess bit=0

if exists (
	select 1 from dbo.userrolesmapping 
	where userid = @CurrentUserId and roleid = 1
)
	begin
		if exists (
			select 1 From dbo.TimesheetWorkflow where TimesheetID = @TimesheetID and datediff(day, submittedon, getutcdate()) > 3 
			)
		begin
			Set @hasAccess=1;
		end
	end

return @hasAccess
end
 

