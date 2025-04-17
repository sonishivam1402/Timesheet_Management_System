

-- GetUserEngagementDetails

CREATE   PROCEDURE [dbo].[GetUserEngagementDetails]
    @UserID INT,
    @Date DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        E.EngagementID,
        E.Title,
        E.Description,
        E.StartDate AS EngagementStartDate,
        E.EndDate AS EngagementEndDate,
        E.EngagementCategoryID,
        M.StartDate AS UserStartDate,
        M.EndDate AS UserEndDate,
        M.MaxWeeklyHours
    FROM 
        dbo.Engagements E
    INNER JOIN 
        dbo.EngagementUserMapping M ON E.EngagementID = M.EngagementID
    WHERE 
        (
            (M.UserID = @UserID
            AND @Date BETWEEN M.StartDate AND ISNULL(M.EndDate, '9999-12-31')
            AND @Date BETWEEN E.StartDate AND ISNULL(E.EndDate, '9999-12-31'))
            OR E.EngagementScopeID = 2 -- Include engagements with EngagementScopeID = 2
        )
        AND E.IsActive = 1
    ORDER BY 
        E.StartDate;
END;