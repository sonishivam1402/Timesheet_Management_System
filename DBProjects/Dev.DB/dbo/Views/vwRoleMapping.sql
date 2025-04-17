CREATE view [dbo].[vwRoleMapping]
as
Select M.MappingId,
M.UserId,U.DisplayName UserName,
M.RoleId,R.RoleName,M.CreatedBy,M.CreatedOn,M.ModifiedOn,M.ModifiedBy
 from dbo.UserRolesMapping M,dbo.RolesMaster R,dbo.Users U
Where M.RoleID=R.RoleId and U.UserId=M.UserId