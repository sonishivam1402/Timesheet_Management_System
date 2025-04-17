USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetLookupValues]    Script Date: 29-11-2024 13:35:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetLookupValues]
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
select 1,'Roles',M.RoleName,M.RoleID from RolesMaster M

insert into @result(CategoryId,CategoryName,[Key],[Value])
Select 2,'Departments',D.DepartmentName,D.DepartmentID From [dbo].[DepartmentMaster] D

insert into @result(CategoryId,CategoryName,[Key],[Value])
Select 3,'Locations',L.LocationName,L.LocationID From [dbo].[LocationsMaster] L

select * from @result
END
GO


