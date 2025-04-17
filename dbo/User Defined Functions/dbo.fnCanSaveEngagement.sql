USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanSaveEngagement]    Script Date: 17-12-2024 17:54:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[fnCanSaveEngagement] (@EngagementId INT, @CurrentUserId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @hasAccess BIT = 0;

	-- Case 1: EngagementId != 0 (Owner is updating existing engagement)
        IF @EngagementId != 0
        BEGIN
            -- check if the user owns the engagement
            IF EXISTS (
                SELECT 1
                FROM EngagementOwnersMapping EOM WITH (NOLOCK)
                WHERE EOM.EngagementId = @EngagementId AND EOM.UserId = @CurrentUserId
            )
            BEGIN
                SET @hasAccess = 1;
            END
        END
        ELSE -- case 2: EngagementId =0 (Manager is creating new engagement)
        BEGIN
            IF EXISTS (
			      SELECT 1
			      FROM UserRolesMapping URM WITH (NOLOCK)
			      WHERE URM.UserId = @CurrentUserId AND URM.RoleId = 2 -- RoleId = 2 for Manager
			  )
			BEGIN
                SET @hasAccess = 1;
            END
        END

    RETURN @hasAccess;
END

 

GO

