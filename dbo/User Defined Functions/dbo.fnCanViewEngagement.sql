USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanViewEngagement]    Script Date: 08-12-2024 02:20:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnCanViewEngagement]
(
    @EngagementId INT,
    @CurrentUserId INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @hasAccess BIT = 0;

    -- Check if the user is a team member in the engagement
    IF EXISTS (
        SELECT 1
        FROM dbo.EngagementUserMapping M WITH (NOLOCK)
        WHERE M.EngagementID = @EngagementId
          AND M.UserID = @CurrentUserId
          AND GETDATE() BETWEEN M.StartDate AND ISNULL(M.EndDate, '9999-12-31')
    )
    BEGIN
        SET @hasAccess = 1;
    END

    -- Check if the engagement is a default engagement (EngagementScopeID = 2)
    ELSE IF EXISTS (
        SELECT 1
        FROM dbo.Engagements E WITH (NOLOCK)
        WHERE E.EngagementID = @EngagementId
          AND E.EngagementScopeID = 2
          AND GETDATE() BETWEEN E.StartDate AND ISNULL(E.EndDate, '9999-12-31')
          AND E.IsActive = 1
    )
    BEGIN
        SET @hasAccess = 1;
    END

    RETURN @hasAccess;
END;
GO

