
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[AddTask]
    @TaskName NVARCHAR(255),
    @TaskDescription NVARCHAR(MAX),
    @IsDeleted BIT,
    @IsGeneric BIT,
    @ModUser INT,
    @TaskID INT OUTPUT 
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.EngagementTasks (TaskName, TaskDescription, IsDeleted, IsGeneric, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
    VALUES (@TaskName, @TaskDescription, 0, 0, @ModUser, @ModUser, GETUTCDATE(), GETUTCDATE());

    SET @TaskID = SCOPE_IDENTITY();
    
    RETURN 0;
END;
