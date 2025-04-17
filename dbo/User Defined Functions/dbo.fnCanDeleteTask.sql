USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanDeleteTask]    Script Date: 17-12-2024 17:51:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fnCanDeleteTask] (@TaskId INT, @CurrentUserId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @hasAccess BIT = 0;

    -- Check if CurrentUserId has a Manager role
    IF EXISTS (
        SELECT 1
        FROM UserRolesMapping URM WITH (NOLOCK)
        WHERE URM.UserId = @CurrentUserId AND URM.RoleId = 2 -- RoleId = 2 for Manager
    )
    BEGIN
        -- Check if there are timesheet lines associated with this task
            IF EXISTS (
                SELECT 1
                FROM TimesheetLines T WITH (NOLOCK)
                WHERE T.TaskID = @TaskId
            )
            BEGIN
                -- Check if all associated timesheets are in pending or rejected states
                IF NOT EXISTS (
                    SELECT 1
                    FROM TimesheetLines T
                    JOIN TimesheetHdr TH ON T.TimesheetID = TH.TimesheetID
                    WHERE T.TaskID = @TaskId
                      AND TH.Status IN (2, 3) -- 2 = Submitted, 3 = Approved
                )
                BEGIN
                    -- Grant access to delete the task
                    SET @hasAccess = 1;
                END
            END
            ELSE
            BEGIN
                -- If no timesheet lines exist, grant access to delete the task
                SET @hasAccess = 1;
            END
        END
    

    RETURN @hasAccess;
END;
GO


