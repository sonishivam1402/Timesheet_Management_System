USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[AddTask]    Script Date: 21-10-2024 10:08:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AddTask]
    @TaskName NVARCHAR(255),
    @TaskDescription NVARCHAR(MAX),
    @IsDeleted BIT,
    @IsGeneric BIT,
    @CreatedBy INT,
    @ModifiedBy INT,
    @CreatedOn DATETIME,
    @ModifiedOn DATETIME,
    @TaskID INT OUTPUT 
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO EngagementTasks (TaskName, TaskDescription, IsDeleted, IsGeneric, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
    VALUES (@TaskName, @TaskDescription, 0, 0, @CreatedBy, @ModifiedBy, GETDATE(), GETDATE());

    SET @TaskID = SCOPE_IDENTITY();
    
    RETURN 0;
END;
GO


