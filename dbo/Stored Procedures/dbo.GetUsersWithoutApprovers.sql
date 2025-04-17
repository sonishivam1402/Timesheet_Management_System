USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetUsersWithoutApprovers]    Script Date: 10-12-2024 00:23:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetUsersWithoutApprovers] 
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		U.UserID,
		U.DisplayName as UserName
		FROM 
		[dbo].[Users] AS U
		WHERE NOT EXISTS 
		(SELECT * 
		FROM 
		[dbo].[UserManagerMapping] AS UMM
		WHERE UMM.UserID = U.UserID)
		GROUP BY UserID, DisplayName

		SELECT COUNT(*) AS Users_Without_PA
			FROM 
			[dbo].[Users] as U
			WHERE NOT EXISTS 
			(SELECT * 
			FROM [dbo].[UserManagerMapping] as UMM 
			WHERE UMM.UserID = U.UserID
		) 

		SELECT COUNT(*) AS Users_Without_SA
			FROM 
			[dbo].[UserManagerMapping] as UMM
			WHERE UMM.isPrimary = 1 AND NOT EXISTS 
			(SELECT 1 
			FROM [dbo].[UserManagerMapping] AS SecUMM 
			WHERE (SecUMM.UserID = UMM.UserID AND SecUMM.isSecondary = 1))
END
GO

