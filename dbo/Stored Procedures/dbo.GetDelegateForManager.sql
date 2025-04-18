USE [UCITMSDev]
GO
/****** Object:  StoredProcedure [dbo].[GetDelegateForManager]    Script Date: 28-11-2024 12:01:11 ******/
DROP PROCEDURE [dbo].[GetDelegateForManager]
GO
/****** Object:  StoredProcedure [dbo].[GetDelegateForManager]    Script Date: 28-11-2024 12:01:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GetDelegateForManager]
@ManagerId INT	
AS 
BEGIN
	SELECT CONCAT(u.DisplayName,
	' (',
	FORMAT(md.StartDate, 'dd - MMM - yyyy'),
	' Till ',
	FORMAT(md.EndDate, 'dd - MMM - yyyy'),
	')') AS 'DelegateTimeSpan'
	FROM [dbo].[ManagerDelegateMapping] md
	INNER JOIN [dbo].[Users] u
	ON md.DelegateId = u.UserId
	where md.ManagerId = @ManagerId;
END
GO
