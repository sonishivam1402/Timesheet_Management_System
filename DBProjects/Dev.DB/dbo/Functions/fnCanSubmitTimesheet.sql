




CREATE function [dbo].[fnCanSubmitTimesheet](@TimesheetId int,@CurrentUserId int)
returns bit
as
Begin
declare @hasAccess bit=0
if exists (
			
			select 1 from dbo.Timesheethdr T with (NoLock) where T.TimesheetId=@TimesheetId and T.UserId=@CurrentUserId
			and T.Status in(1,4)
			)
	begin
		Set @hasAccess=1
	end
return @hasAccess
end