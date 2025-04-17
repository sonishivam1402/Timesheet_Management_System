USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[AdminDashboardInfo]    Script Date: 26-11-2024 18:08:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[AdminDashboardInfo]
AS
BEGIN

declare @result  table
(
CategoryId int,
CategoryName varchar(50),
[Key] varchar(100),
[Value] int
)



insert into @result(CategoryId,CategoryName,[Key],[Value])
select 1,'Roles',M.RoleName,Count(U.UserID) as Cnt from [dbo].[UserRolesMapping] U,RolesMaster M
where M.RoleID=U.RoleID
Group By  M.RoleName

insert into @result(CategoryId,CategoryName,[Key],[Value])
Select 2,'EngagemnetScopes',S.Description,count(E.EngagementId) cnt From [dbo].[Engagements] E,[dbo].[EngagementScopeMaster] S
where E.EngagementScopeID=S.ScopeId
Group By S.Description


insert into @result(CategoryId,CategoryName,[Key],[Value])
Select 3,'Departments',D.DepartmentName,count(U.UserId) cnt From [dbo].[Users] U,[dbo].[DepartmentMaster] D
where U.Department=D.DepartmentId
Group By D.DepartmentName

insert into @result(CategoryId,CategoryName,[Key],[Value])

Select 4,'Locations',L.LocationName,count(U.UserId) cnt From [dbo].[Users] U,[dbo].[LocationsMaster] L
where U.Location=L.LocationId
Group By  L.LocationName

select * from @result
END
GO


