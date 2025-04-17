
CREATE function [dbo].[udfEmployeeTasks](@UserId int)
returns @tbl table
(
EngagementId int,
EngagementName varchar(200),
TaskId int,
TaskName varchar(200),
StartDate Date,
EndDate date,
Scope varchar(100),
isActive bit default(1)
)
as
Begin

----Engagment Specific To this user -------------
insert into @tbl(EngagementId,TaskId,startDate,Enddate,Scope,isActive)
select ETM.EngagementID,ETM.TaskId,EUM.StartDate,EUM.EndDate,'Custom',1 from 
dbo.EngagementTaskMapping ETM with (NoLock),
[dbo].[EngagementUserMapping] EUM with (NoLock)
Where 
EUM.UserId=@UserId
and EUM.EngagementID=ETM.EngagementID
and getdate() between EUM.StartDate and EUM.EndDate 

---Engagment inherited from Global Scope----
insert into @tbl(EngagementId,TaskId,startDate,Enddate,Scope,isActive)
select ETM.EngagementID,ETM.TaskId,E.StartDate,E.EndDate,'Global',1 from 
dbo.EngagementTaskMapping ETM with (NoLock),
[dbo].Engagements E with (NoLock)
Where 
 E.EngagementID=ETM.EngagementID
and getdate() between E.StartDate and E.EndDate 
and E.EngagementScopeId=2
and isnull(E.IsActive,1)=1


---Updating Name of Engagment
Update T  set T.EngagementName=e.title from @tbl T,Engagements e with (noLock)
where T.EngagementID=e.EngagementID

---Updating Name of Tasks
Update T  set T.TaskName=Task.TaskName from @tbl T,[dbo].[EngagementTasks]Task  with (noLock)
where T.TaskId=task.TaskID

return
End