--select * from dbo.TimesheetHdr
--Exec  dbo.GetRejectEmailContent @TimesheetId=56
CREATE proc [dbo].[GetRejectEmailContent]
@TimesheetId as int
as
Begin
declare @result table(
TimesheetId int,
EmployeeName varchar(100),
EmployeeEmail varchar(100),
ManagerName varchar(100),
TimesheetDuration varchar(100),
RejectionComment varchar(100)
)


---Get Employee Details--
insert into @result(TimesheetId,EmployeeName,EmployeeEmail,TimesheetDuration)
select @TimesheetId,U.DisplayName,U.Email,[dbo].[GetTimeSheetTitle](TS.StartDate,TS.EndDate) from dbo.TimesheetHdr TS ,users U 
where TS.UserId=U.UserId
and TS.TimesheetId=@TimesheetId


--Get Workflow Details
Update R 
Set R.ManagerName=manager.DisplayName,
R.RejectionComment=TWF.RejectionComment
from 
@result R,dbo.TimesheetWorkflow TWF,Users manager
where R.TimesheetId=TWF.TimesheetID
and manager.UserId=TWF.[RejectedBy]


Select * From @result

end
