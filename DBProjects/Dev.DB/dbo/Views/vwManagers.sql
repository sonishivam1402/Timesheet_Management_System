Create view [dbo].[vwManagers]
as
select M.UserId,U.DisplayName from UserRolesMapping M with (NOLOck) ,Users U with (NoLock) 
where M.Roleid=2 and U.UserId=M.UserId
union
select M.DelegateID,U.DisplayName from [dbo].[ManagerDelegateMapping] M with (NOLOck) ,Users U with (NoLock) 
where U.UserId=M.DelegateID