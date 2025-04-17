CREATE view [dbo].[vwUserRoles]
as

SELECT UserId,UserName, RoleIds = 
    STUFF((SELECT ', ' + cast(RoleId as varchar(10))
           FROM dbo.vwRoleMapping b 
           WHERE b.UserId = a.UserId 
          FOR XML PATH('')), 1, 2, ''),
		  RoleNames = 
    STUFF((SELECT ', ' + cast(RoleName as varchar(10))
           FROM dbo.vwRoleMapping b 
           WHERE b.UserId = a.UserId 
          FOR XML PATH('')), 1, 2, ''),
		  Count(1) as RoleCount

FROM dbo.vwRoleMapping a
GROUP BY UserId,UserName