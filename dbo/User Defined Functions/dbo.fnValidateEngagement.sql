USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnValidateEngagement]    Script Date: 26-12-2024 18:00:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Object:  UserDefinedFunction [dbo].[fnValidateEngagement] ******/
CREATE FUNCTION [dbo].[fnValidateEngagement] 
(
    @ModUser INT,
    @EngagementOwners dbo.EngagementOwnerType READONLY,
    @TeamMembers dbo.TeamMemberType READONLY
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsValid BIT = 1;

    -- Check if ModUser is part of the owners table
    IF NOT EXISTS (
        SELECT 1
        FROM @EngagementOwners
        WHERE UserID = @ModUser
    )
    BEGIN
        SET @IsValid = 0;
        RETURN @IsValid;
    END

    -- Check if all owners are part of the team member table
    IF EXISTS (
        SELECT 1
        FROM @EngagementOwners eo
        WHERE NOT EXISTS (
            SELECT 1
            FROM @TeamMembers tm
            WHERE eo.UserID = tm.UserID
        )
    )
    BEGIN
        SET @IsValid = 0;
        RETURN @IsValid;
    END

    -- Check if all users in owners and team members are active users
    IF EXISTS (
        SELECT 1
        FROM @EngagementOwners eo
        WHERE NOT EXISTS (
            SELECT 1
            FROM [dbo].[Users] u
            WHERE eo.UserID = u.UserID AND u.IsActive = 1
        )
    )
    BEGIN
        SET @IsValid = 0;
        RETURN @IsValid;
    END

    IF EXISTS (
        SELECT 1
        FROM @TeamMembers tm
        WHERE NOT EXISTS (
            SELECT 1
            FROM [dbo].[Users] u
            WHERE tm.UserID = u.UserID AND u.IsActive = 1
        )
    )
    BEGIN
        SET @IsValid = 0;
        RETURN @IsValid;
    END

    RETURN @IsValid;
END;
GO

