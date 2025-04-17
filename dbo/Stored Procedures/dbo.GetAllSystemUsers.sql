USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetAllSystemUsers]    Script Date: 02-12-2024 15:54:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GetAllSystemUsers]
AS
BEGIN

    SELECT 
        U.[UserID],
        U.[DisplayName],
        U.[Email],
		U.[ModifiedBy],
		UM.[DisplayName] AS ModifiedByName,
		U.[ModifiedOn],
        U.[IsActive],
        U.[EmployeeID],
        U.[Location] AS LocationID,
        LM.[LocationName],
        U.[Department] As DepartmentID,
		DM.[DepartmentName],
        vwUR.RoleIds As UserRoles,
		  vwUR.RoleNames As UserRoleName
    FROM 
        [dbo].[Users] AS U
	LEFT JOIN 
        [dbo].[LocationsMaster] AS LM
        ON U.[Location] = LM.[LocationID]
	LEFT JOIN 
        [dbo].[DepartmentMaster] AS DM
        ON U.[Department] = DM.[DepartmentID]
	left join dbo.vwUserRoles as vwUR
	on  vwUR.UserId=U.UserId
	LEFT JOIN 
		[dbo].[Users] AS UM 
		ON UM.[UserID] = U.[ModifiedBy]
    Order By U.DisplayName
END;
GO


