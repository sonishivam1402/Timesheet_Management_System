CREATE PROCEDURE [dbo].[GetLookupValues](@LookupIds varchar(1000))
AS
BEGIN

declare @result  table
(
CategoryId int,
CategoryName varchar(50),
[Key] varchar(100),
[Value] int
)

declare @RoleTable varchar(50)='3228D5A1-DA07-45AC-8F99-CDE6C239EC6B'
declare @DepartmentTable varchar(50) ='739F2F0D-76F0-4FB9-A778-B97AE5173629'
declare @LocationTable varchar(50)='E771BF28-E6E9-4263-B9F4-29D80B38C8E0'
declare @EngagementScopeMasterTable varchar(50)='AAFE9F22-1E4B-4E56-BEA0-63637832CADD'
declare @StatusMasterTable varchar(50)='4BC4C859-9FDB-43C4-BD8E-060C7C517856'

if exists(select 1 from String_split(@LookupIds,',') where Value=@RoleTable)
	Begin
		insert into @result(CategoryId,CategoryName,[Key],[Value])
		select 1,'Roles',M.RoleName,M.RoleID from RolesMaster M

	end

if exists(select 1 from String_split(@LookupIds,',') where Value=@DepartmentTable)
	Begin
		insert into @result(CategoryId,CategoryName,[Key],[Value])
		Select 2,'Departments',D.DepartmentName,D.DepartmentID From [dbo].[DepartmentMaster] D

	end

if exists(select 1 from String_split(@LookupIds,',') where Value=@LocationTable)
	Begin
		insert into @result(CategoryId,CategoryName,[Key],[Value])
		Select 3,'Locations',L.LocationName,L.LocationID From [dbo].[LocationsMaster] L


	end

if exists(select 1 from String_split(@LookupIds,',') where Value=@EngagementScopeMasterTable)
	Begin
		insert into @result(CategoryId,CategoryName,[Key],[Value])
		Select 4,'Engagement Scopes',E.Description,E.ScopeID From [dbo].[EngagementScopeMaster] E


	end

if exists(select 1 from String_split(@LookupIds,',') where Value=@StatusMasterTable)
	Begin
		insert into @result(CategoryId,CategoryName,[Key],[Value])
		Select 5,'Engagement Status',S.StatusName,S.StatusId From [dbo].[StatusMaster] S


	end


select * from @result
END