CREATE procedure [dbo].[GetEmployeesAssignedtoManagerbyManagerID]
@managerid int
as 
begin
select u.displayname as 'Employee Name',
	case when umm.isprimary = 1 then 'Primary'
		 when umm.issecondary = 1 then 'Secondary'
	end as [Approver Type]
from
	[dbo].[UserManagerMapping] umm inner join [dbo].[Users] u on umm.userid = u.userid
	where umm.managerid = @managerid;
end
