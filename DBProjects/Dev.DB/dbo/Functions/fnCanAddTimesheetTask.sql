


--select * from EngagementTaskMapping


CREATE function [dbo].[fnCanAddTimesheetTask](@TaskId int,@CurrentUserId int)
returns bit
as
Begin


declare @hasAccess bit=0
if exists (
			select 1 From dbo.udfEmployeeTasks(@CurrentUserId) Where TaskId=@TaskId

			)
	begin
		Set @hasAccess=1
	end
return @hasAccess
end