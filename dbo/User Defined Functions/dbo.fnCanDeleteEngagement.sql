USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanDeleteEngagement]    Script Date: 13-12-2024 01:00:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnCanDeleteEngagement] (@EngagementId INT, @CurrentUserId INT)
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
        -- Check if the manager owns the engagement
        IF EXISTS (
            SELECT 1
            FROM EngagementOwnersMapping EOM WITH (NOLOCK)
            WHERE EOM.EngagementId = @EngagementId AND EOM.UserId = @CurrentUserId
        )
        BEGIN
            -- Check if there are timesheet lines associated with this engagement
            IF EXISTS (
                SELECT 1
                FROM TimesheetLines T WITH (NOLOCK)
                WHERE T.EngagementID = @EngagementId
            )
            BEGIN
                -- Check if all associated timesheets are in pending or rejected states
                IF NOT EXISTS (
                    SELECT 1
                    FROM TimesheetLines T
                    JOIN TimesheetHdr TH ON T.TimesheetID = TH.TimesheetID
                    WHERE T.EngagementID = @EngagementId
                      AND TH.Status IN (2, 3) -- 2 = Submitted, 3 = Approved
                )
                BEGIN
                    

                    -- Grant access to delete the engagement
                    SET @hasAccess = 1;
                END
            END
            ELSE
            BEGIN
                -- If no timesheet lines exist, grant access to delete the engagement
                SET @hasAccess = 1;
            END
        END
    END

    RETURN @hasAccess;
END;
GO

