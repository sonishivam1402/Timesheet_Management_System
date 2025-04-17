
/*
This should return true
[dbo].[isAuthorized] @autherizationTypeId=1,@Itemid=21,@CurrentUserId=7

This should return false
[dbo].[isAuthorized] @autherizationTypeId=1,@Itemid=92,@CurrentUserId=7

This should return false
[dbo].[isAuthorized] @autherizationTypeId=3,@Itemid=27,@CurrentUserId=9

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
if exists (
			select 1 from TimesheetHdr T with (noLock) where T.TimesheetId=@TimesheetId and T.UserId=@CurrentUserId
			)
	begin
		Set @hasAccess=1
	end
End


---CHECK FOR Edit Access on Timesheet
If @autherizationTypeId=4
Begin
if exists (
			select 1 from TimesheetHdr T with (noLock) where T.TimesheetId=@TimesheetId and T.UserId=@CurrentUserId
			)
	begin
		Set @hasAccess=1
	end
End

---CHECK FOR Review Access on Timesheet
If @autherizationTypeId=5
Begin
if exists (
			select 1 from [dbo].[UserManagerMapping] with (noLock)  where UserId in(
			select UserId from TimesheetHdr T with (noLock) where T.TimesheetId=@TimesheetId 
			) and ManagerID=@CurrentUserId
			)
	begin
		Set @hasAccess=1
	end
End

Select @hasAccess as [HasAccess]
End

