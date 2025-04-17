--GetEngagementsForEmployee

CREATE   PROCEDURE [dbo].[GetEngagementsForEmployee] 
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT 
        E.EngagementID,
        E.Title,
        ISNULL(EUM.StartDate, E.StartDate) AS StartDate,
        ISNULL(EUM.EndDate, E.EndDate) AS EndDate,
        E.Description,
        E.CreatedBy,
        E.ModifiedBy,
        E.ModifiedOn,
        E.CreatedOn,
        E.IsActive,
        E.EngagementCategoryID,
        
        (SELECT STRING_AGG(UO.DisplayName, ', ') 
         FROM dbo.EngagementOwnersMapping EOM
         INNER JOIN dbo.Users UO ON EOM.UserID = UO.UserID
         WHERE EOM.EngagementID = E.EngagementID) AS Owners,

        (SELECT STRING_AGG(TM.DisplayName, ', ') 
         FROM dbo.EngagementUserMapping EUM
         INNER JOIN dbo.Users TM ON EUM.UserID = TM.UserID
         WHERE EUM.EngagementID = E.EngagementID) AS TeamMembers
    FROM 
        dbo.Engagements E
    LEFT JOIN 
        dbo.EngagementOwnersMapping EOM ON E.EngagementID = EOM.EngagementID
    LEFT JOIN 
        dbo.EngagementUserMapping EUM ON E.EngagementID = EUM.EngagementID AND EUM.UserID = @UserID
    WHERE 
        (EOM.UserID = @UserID OR EUM.UserID = @UserID OR E.EngagementScopeID = 2) -- Include EngagementScopeID = 2
        AND E.IsActive = 1;
END;