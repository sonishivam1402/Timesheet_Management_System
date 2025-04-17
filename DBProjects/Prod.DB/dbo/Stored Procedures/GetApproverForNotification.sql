CREATE procedure [dbo].[GetApproverForNotification]
as
Begin
select Distinct ManagerID,U.DisplayName as ManagerName,U.Email ManagerEmail from UserManagerMapping UM, Users U where 
UM.ManagerID=U.UserId 
and UM.isPrimary=1
and 
UM.UserId in
(
select T.UserId from dbo.TimesheetHdr T,dbo.TimesheetWorkflow W where T.Status=2
and T.TimesheetID=W.TimesheetID  and isnull(W.SubmitNotificationSent,0)=0
)
End
