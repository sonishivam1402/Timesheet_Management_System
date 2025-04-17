

/*
This should return true
[dbo].[isAuthorized] @autherizationTypeId=1,@Itemid=21,@CurrentUserId=7

This should return false
[dbo].[isAuthorized] @autherizationTypeId=1,@Itemid=92,@CurrentUserId=7

This should return false
[dbo].[isAuthorized] @autherizationTypeId=3,@Itemid=53,@CurrentUserId=16

select * From TimesheetHdr
select * from Menu
*/
CREATE procedure [dbo].[isAuthorized]
@autherizationTypeId int = 0,
@Itemid int = 0,
@CurrentUserId int = 0
as
begin
/*
autherizationTypeId 
1:Menu
2:custom action
3:ReadTimesheet (Here ItemId will be TImesheetId)
4:EditTimesheet (Here ItemId will be TImesheetId)
5:ReviewTimesheet (Here ItemId will be TImesheetId)
6:Can SubmitTimesheet (Here ItemId will be TImesheetId)

*/

declare @hasAccess bit=0

---CHECK FOR ACCESS ON MENUS
If @autherizationTypeId=1
Begin
if exists (
			select 1 from [dbo].[MenuRoleMapping] m inner join 
			[dbo].[UserRolesMapping] u on m.roleid = u.roleid 
			where m.menuid = @Itemid and u.userid = @CurrentUserId)
	begin
		Set @hasAccess=1
	end

End

---CHECK FOR Read Access on Timesheet
declare @TimesheetId int=@itemid
If @autherizationTypeId=3
Begin
	Select @hasAccess=[dbo].[fnCanReadTimesheet](@itemid,@CurrentUserId)
End


---CHECK FOR Edit Access on Timesheet
If @autherizationTypeId=4
Begin
	Select @hasAccess=[dbo].[fnCanEditTimesheet](@itemid,@CurrentUserId)
End

---CHECK FOR Review Access on Timesheet
If @autherizationTypeId=5
Begin
Select @hasAccess=[dbo].[fnCanReviewTimesheet](@itemid,@CurrentUserId)
End

---CHECK FOR Can Submit Timesheet
If @autherizationTypeId=6
Begin
Select @hasAccess=[dbo].[fnCanSubmitTimesheet](@itemid,@CurrentUserId)
End

---CHECK FOR Add Edit  timesheet line
If @autherizationTypeId=7
Begin
Select @hasAccess=[dbo].[fnCanAddEditTimesheetLine](@itemid,@CurrentUserId)
End

---CHECK FOR  delete	timesheet line
If @autherizationTypeId=8
Begin
Select @hasAccess=[dbo].[fnCanDeleteTimesheetLine](@itemid,@CurrentUserId)
End

---CHECK FOR  Save	Engagment
If @autherizationTypeId=9
Begin
Select @hasAccess=[dbo].[fnCanSaveEngagement](@itemid,@CurrentUserId)
End

---CHECK FOR View Engagment
If @autherizationTypeId=10
Begin
Select @hasAccess=[dbo].[fnCanViewEngagement](@itemid,@CurrentUserId)
End

---CHECK FOR Inactivate notification
If @autherizationTypeId=11
Begin
Select @hasAccess=[dbo].[fnCanInactiveNotification](@itemid,@CurrentUserId)
End

---CHECK FOR Inactivate notification
If @autherizationTypeId=12
Begin
Select @hasAccess=[dbo].[fnCanAddTimesheetTask](@itemid,@CurrentUserId)
End

Select @hasAccess as [HasAccess]
End