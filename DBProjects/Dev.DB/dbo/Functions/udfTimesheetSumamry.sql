CREATE function [dbo].[udfTimesheetSumamry]()
returns @tbl table
(
TimesheetId int,
LineId int,
UserId int,
[Employee] Varchar(200),
ManagerId int,
ManagerName varchar(100),
SecondaryManagerId int,
SecondaryManagerName varchar(100),
SubmittedOn datetime,
ApprovedOn datetime,
ApprovedBy int,
ApprovedByName varchar(100),
StartDate date,
EndDate date,
StatusId int,
StatusName varchar(20),
Duration varchar(80),
EngagementID int,
EngagementName varchar(200),
TaskID int,
TaskName varchar(200),
EntryDate date,
Hours int,
Minutes int,
TotalHours float,
Comments varchar(500)
)
as
Begin
insert into @tbl(TimesheetId,LineId, UserId,[Employee],StartDate,EndDate,StatusId,
StatusName,Duration,
EngagementID,EngagementName,TaskID,TaskName,
EntryDate,Hours,Minutes,TotalHours,Comments)
select  H.TimesheetID,L.LineID, U.UserId,U.DisplayName as [Employee],H.StartDate,H.EndDate,SM.StatusId,
SM.StatusName,dbo.GetTimeSheetTitle(H.StartDate,H.EndDate) as Duration,
E.EngagementID,E.Title [Engagement],L.TaskID,task.TaskName [Task],L.Date,L.Hours,L.Minutes, 
round((cast(((60*L.Hours)+L.Minutes) as float)/cast(60 as float)),2)  as [TotalHours]
,L.Comment
from 
dbo.Timesheethdr H,Users U,TimesheetLines L,Engagements E,EngagementTasks task,
dbo.StatusMaster SM
Where H.UserId=U.UserID and L.TimesheetID=H.TimesheetID
and E.EngagementID=L.EngagementID
and task.TaskID=L.TaskID
and SM.StatusId=H.Status

--Primary Manager
Update T set ManagerId=uManger.UserId,ManagerName=uManger.DisplayName
From @Tbl T,UserManagerMapping U,Users uManger
where U.ManagerId=uManger.UserId and isPrimary=1
and T.UserId=U.UserID

---Secondary Manager
Update T set SecondaryManagerId=uManger.UserId,SecondaryManagerName=uManger.DisplayName
From @Tbl T,UserManagerMapping U,Users uManger
where U.ManagerId=uManger.UserId and isSecondary=1
and T.UserId=U.UserID

--Submitted/APproved On
--Select * From [dbo].[TimesheetWorkflow] where TImesheetid=95
Update T set SubmittedOn=W.SubmittedOn
,ApprovedOn=W.ApprovedOn  ,  ApprovedBy =W.ApprovedBy,
ApprovedByName =userApproved.DisplayName
From @Tbl T
Join [dbo].[TimesheetWorkflow] W on T.TimesheetId=W.TimesheetId
left Join Users userApproved on W.ApprovedBy=userApproved.UserId


return
End

--select * From dbo.udfTimesheetSumamry()