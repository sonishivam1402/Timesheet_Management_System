




CREATE FUNCTION [dbo].[fnCanSaveEngagement] (@EngagementId INT, @CurrentUserId INT)
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
        -- Case 1: EngagementId = 0 (Manager creating a new engagement)
        IF @EngagementId = 0
        BEGIN
            SET @hasAccess = 1;
        END
        ELSE
        BEGIN
            -- Case 2: EngagementId is not 0, check if the manager owns the engagement
            IF EXISTS (
                SELECT 1
                FROM EngagementOwnersMapping EOM WITH (NOLOCK)
                WHERE EOM.EngagementId = @EngagementId AND EOM.UserId = @CurrentUserId
            )
            BEGIN
                SET @hasAccess = 1;
            END
        END
    END

    RETURN @hasAccess;
END