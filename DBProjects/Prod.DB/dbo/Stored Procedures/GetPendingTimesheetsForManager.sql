
--Exec dbo.GetPendingTimesheetsForManager @ManagerId=7
CREATE procedure [dbo].[GetPendingTimesheetsForManager]
@ManagerId int
as
Begin

select U.UserId,U.Email,U.DisplayName,T.ModifiedOn as SubmittedOn,'Week Ending on 6/11' as TimeSheetPeriod from dbo.TimesheetHdr T,Users U where 
U.UserId=T.UserId
and T.Status=2
and T.UserId in
(
select UserId From UserManagerMapping where ManagerId=@ManagerId and isPrimary=1
)
End
