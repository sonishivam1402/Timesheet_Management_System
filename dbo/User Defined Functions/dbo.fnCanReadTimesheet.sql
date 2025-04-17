USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanReadTimesheet]    Script Date: 08-12-2024 02:19:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnCanReadTimesheet]
(
    @TimesheetId INT,
    @CurrentUserId INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @hasAccess BIT = 0;

    -- Case 1: Current user is the owner of the timesheet
    IF EXISTS (
        SELECT 1 
        FROM TimesheetHdr T WITH (NOLOCK)
        WHERE T.TimesheetId = @TimesheetId AND T.UserId = @CurrentUserId
    )
    BEGIN
        SET @hasAccess = 1;
    END

    -- Case 2: Current user is the manager of the employee owning the timesheet
    IF EXISTS (
        SELECT 1 
        FROM [dbo].[UserManagerMapping] UMM WITH (NOLOCK)
        WHERE UMM.UserId IN (
            SELECT T.UserId
            FROM TimesheetHdr T WITH (NOLOCK)
            WHERE T.TimesheetId = @TimesheetId
        )
        AND UMM.ManagerID = @CurrentUserId
    )
    BEGIN
        SET @hasAccess = 1;
    END

    -- Case 3: Current user is a delegate of the manager for the employee owning the timesheet
    IF EXISTS (
        SELECT 1
        FROM [dbo].[UserManagerMapping] UMM WITH (NOLOCK)
        INNER JOIN [dbo].[ManagerDelegateMapping] MDM WITH (NOLOCK)
            ON UMM.ManagerID = MDM.ManagerID
        WHERE UMM.UserId IN (
            SELECT T.UserId
            FROM TimesheetHdr T WITH (NOLOCK)
            WHERE T.TimesheetId = @TimesheetId
        )
        AND MDM.DelegateID = @CurrentUserId
        AND GETUTCDATE() BETWEEN MDM.StartDate AND MDM.EndDate
    )
    BEGIN
        SET @hasAccess = 1;
    END

    RETURN @hasAccess;
END
GO

