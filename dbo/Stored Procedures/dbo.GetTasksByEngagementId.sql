USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetTasksByEngagementId]    Script Date: 08-01-2025 14:44:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[GetTasksByEngagementId] 
	@EngagementID INT = NULL 
AS
BEGIN

    -- Select tasks related to engagement(s)
    SELECT 
        ETM.EngagementID,
        ET.TaskID,
        ET.TaskName
    FROM 
        dbo.EngagementTaskMapping ETM
    INNER JOIN 
        dbo.EngagementTasks ET ON ETM.TaskID = ET.TaskID
    WHERE 
        (@EngagementID IS NULL OR ETM.EngagementID = @EngagementID)
	Order By ET.TaskName

End
GO


