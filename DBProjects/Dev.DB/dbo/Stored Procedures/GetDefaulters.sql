
--Exec dbo.GetDefaulters @ManagerId=0,@UserId=15
CREATE Procedure [dbo].[GetDefaulters] (@ManagerId int=0,@UserId int=0)
as
Begin
DECLARE @StartDateTime DATETIME
DECLARE @EndDateTime DATETIME
 

-----LOGIC FOR GETTING Data  ONLY FOR 1 USER -----
if isnull(@UserId,0)<>0
	Select @ManagerId=ManagerID from dbo.UserManagerMapping U with (NoLock) Where U.UserID=@UserId and isPrimary=1 

------------------------------------------------

select @StartDateTime=cast(value as date) from dbo.Configuration where ID=1
SET @EndDateTime = GETDATE();

declare @tblData table(
RowId int identity(1,1),
UserId int,
ManagerId int,
StartDate date,
DueDate date,
hasDraft bit default(0),
hasSubmitted bit default(0),
hasDefaulted bit default(0)

);

WITH DateRange(DateData) AS 
(
    SELECT @StartDateTime as Date
    UNION ALL
    SELECT DATEADD(d,1,DateData)
    FROM DateRange 
    WHERE DateData < @EndDateTime 
)
insert into @tblData(ManagerId,UserId,StartDate)
SELECT ManagerId,UserId,cast(DateData as Date)
FROM DateRange,[dbo].[UserManagerMapping] where  datename(dw,DateData)='Monday'
and ManagerID=@ManagerId order by ManagerId,UserId
OPTION (MAXRECURSION 0)
--select ManagerId,UserId from [dbo].[UserManagerMapping] where ManagerID=@ManagerId


-----REMOVE ALL OTHER USERS IF WE NEED DATA ONLY FOR 1 USER -----
if isnull(@UserId,0)<>0
	Delete from @tblData where UserId<>@UserId 

------------------------------------------------

--Now Remove dates for the users where Employee Start date is after system start date
Delete @tblData from 
@tblData T,dbo.Users U
where T.UserId=U.UserId and U.TimesheetStartDate is not null
and T.StartDate<U.TimesheetStartDate


---MARK THE DUE DATE (10 Days after start date)----
Update T set DueDate=DATEADD(d,9, StartDate) From @tblData  T


--Exec dbo.GetDefaulters @ManagerId=5,@UserId=0
---CHECK IF USER HAS ANY TIMESHEET IN DRAFT STATE FOR THE DATES ---
Update T set hasDraft=1
From @tblData T,dbo.TimesheetHdr H
where T.UserId=H.UserID
and H.Status=1
and cast(T.StartDate as date)=cast(H.StartDate as date)

---CHECK IF USER HAS ANY TIMESHEET IN SUBMITTED+Approved STATE FOR THE DATES ---
Update T set hasSubmitted=1
From @tblData T,dbo.TimesheetHdr H
where T.UserId=H.UserID
and H.Status in (2,3)
and cast(T.StartDate as date)=cast(H.StartDate as date)

Update @tblData Set hasDefaulted =1 where hasSubmitted<>1
--Exec dbo.GetDefaulters @ManagerId=0,@UserId=5
Select M.DisplayName as [Manager],U.DisplayName as [User],[dbo].[GetTimeSheetDuration](T.startdate,
dateadd(d,4,T.startdate)) as Duration,
T.* 
From @tblData T,Users U,Users M where hasDefaulted=1
and U.UserId=T.UserId and M.UserId=T.ManagerId 
and T.DueDate<getdate()

order by M.DisplayName,U.DisplayName,T.StartDate


end