
CREATE      PROCEDURE [dbo].[GetNotifyApproverMail]
@ManagerId as int,
@UserId as int,
@TimesheetID as int
AS 
BEGIN

select T.TimesheetID,T.UserID,usrSubmitteBy.DisplayName [UserName], T.StartDate,T.EndDate,
T.Status,W.SubmittedOn ,DATEDIFF(DAY, W.SubmittedOn, GetUTCDate()) DaysDue,0 as ManagerId,
cast('' as varchar(100)) as ManagerName,  cast('' AS VARCHAR(100)) AS ManagerEmail, dbo.GetTimeSheetDuration (t.startdate, t.enddate) as tsDuration, W.SubmissionComment
into #TempData

from TimesheetHdr T,  [dbo].[TimesheetWorkflow] W,Users usrSubmitteBy
where T.Status=2
and T.TimesheetId=W.TimesheetId
and usrSubmitteBy.UserID=T.UserID

----Getting Manager for the users ---

Update T Set ManagerId=UM.ManagerID,ManagerName=usrManger.DisplayName, ManagerEmail = usrManger.Email
From #TempData T,dbo.UserManagerMapping UM,Users usrManger
where T.UserID=UM.UserId and UM.ManagerId=usrManger.UserId
and UM.isPrimary=1

Select * from #TempData WHERE (@ManagerId IS NULL OR ManagerId = @ManagerId) AND (@UserId IS NULL OR UserId = @UserId) AND (@TimesheetID IS NULL OR TimesheetID  = @TimesheetID ) order by DaysDue desc

drop table #TempData
END