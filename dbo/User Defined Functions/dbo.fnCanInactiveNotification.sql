USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanInactiveNotification]    Script Date: 09-12-2024 14:53:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnCanInactiveNotification]
(
    @RecordId INT,
    @CurrentUserId INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @hasAccess BIT = 0;

    -- Check if the RecordId belongs to the CurrentUserId in the NotificationRecord table
    IF EXISTS (
        SELECT 1
        FROM [dbo].[NotificationRecord]
        WHERE RecordId = @RecordId
          AND UserId = @CurrentUserId
    )
    BEGIN
        SET @hasAccess = 1;
    END

    RETURN @hasAccess;
END
GO

