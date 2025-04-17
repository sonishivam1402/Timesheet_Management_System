USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[DeleteEngagement]    Script Date: 13-12-2024 14:36:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteEngagement]
    @EngagementId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @canDelete BIT;

    -- Check if the engagement can be deleted
    SET @canDelete = dbo.fnCanDeleteEngagement(@EngagementId, @UserId);

    -- If deletion is allowed
    IF @canDelete = 1
    BEGIN
        DELETE FROM TimesheetLines WHERE EngagementId = @EngagementId;
        BEGIN TRY
            BEGIN TRANSACTION;

            -- Delete from related tables
            DELETE FROM EngagementOwnersMapping WHERE EngagementId = @EngagementId;
            DELETE FROM EngagementUserMapping WHERE EngagementId = @EngagementId;
            DELETE FROM EngagementTaskMapping WHERE EngagementId = @EngagementId;
            DELETE FROM Engagements WHERE EngagementId = @EngagementId;

            COMMIT TRANSACTION;

            SELECT 
                1 AS CanDelete, 
                'Engagement deleted successfully.' AS Message;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;

            SELECT 
                0 AS CanDelete, 
                'An error occurred while deleting the engagement.' AS Message;
        END CATCH;
    END
    ELSE
    BEGIN
        -- Check for associated timesheets in submitted or approved state
        DECLARE @TimesheetDetails NVARCHAR(MAX) = '';

        -- Use a temporary table to store distinct values
        CREATE TABLE #TempTimesheetDetails (
            Message NVARCHAR(MAX)
        );

        -- Insert distinct concatenated values into the temporary table
        INSERT INTO #TempTimesheetDetails (Message)
        SELECT DISTINCT
            CONCAT(
                U.DisplayName, ' ', 
                dbo.GetTimeSheetTitle(TH.StartDate, TH.EndDate), ' ', 
                CASE 
                    WHEN TH.Status = 2 THEN 'Submitted' 
                    WHEN TH.Status = 3 THEN 'Approved' 
                    ELSE 'Unknown'
                END
            )
        FROM TimesheetHdr TH
        JOIN TimesheetLines TL ON TH.TimesheetID = TL.TimesheetID
        JOIN Engagements E ON TL.EngagementID = E.EngagementID
        JOIN Users U ON TH.UserID = U.UserId
        WHERE TL.EngagementID = @EngagementId
          AND TH.Status IN (2, 3);

        -- Aggregate results from the temporary table
        SELECT @TimesheetDetails = STRING_AGG(Message, ',')
        FROM #TempTimesheetDetails;

        -- Drop the temporary table
        DROP TABLE #TempTimesheetDetails;

        -- Return results or unauthorized message
        IF @TimesheetDetails IS NOT NULL AND LEN(@TimesheetDetails) > 0
        BEGIN
            SELECT 
                0 AS CanDelete, 
                @TimesheetDetails AS Message;
        END
        ELSE
        BEGIN
            SELECT 
                0 AS CanDelete, 
                'You are not authorized to delete this engagement.' AS Message;
        END
    END
END;
GO

