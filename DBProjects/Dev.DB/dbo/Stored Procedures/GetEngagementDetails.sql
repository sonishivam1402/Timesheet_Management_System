




CREATE   PROCEDURE [dbo].[GetEngagementDetails]
    @EngagementID INT = NULL -- If NULL, it will return all engagements
AS
BEGIN
	-- Update IsActive status based on StartDate and EndDate
    UPDATE dbo.Engagements
    SET IsActive = CASE 
                        WHEN StartDate > GETDATE() OR EndDate < GETDATE() THEN 0 
                        ELSE 1 
                   END
    WHERE 
		IsActive <> 0 AND (@EngagementID IS NULL OR EngagementID = @EngagementID);

    -- Select engagement details
    SELECT 
        E.EngagementID,
        E.Title,
        E.StartDate,
        E.EndDate,
        E.Description,
        E.CreatedBy,
        --U.DisplayName AS CreatedByName,
        E.ModifiedBy,
        --U2.DisplayName AS ModifiedByName,
        E.ModifiedOn,
        E.CreatedOn,
        E.IsActive,
        E.EngagementCategoryID
    FROM 
        dbo.Engagements E
    LEFT JOIN 
        dbo.Users U ON E.CreatedBy = U.UserID
    LEFT JOIN 
        dbo.Users U2 ON E.ModifiedBy = U2.UserID
    WHERE 
        (@EngagementID IS NULL OR E.EngagementID = @EngagementID);
	

    

    -- Select tasks related to engagement(s)
    SELECT 
        ETM.EngagementTaskID,
        ETM.EngagementID,
        ET.TaskID,
        ET.TaskName,
        ET.TaskDescription,
        ET.CreatedBy,
        ET.ModifiedBy,
        ET.ModifiedOn,
        ET.CreatedOn
    FROM 
        dbo.EngagementTaskMapping ETM
    INNER JOIN 
        dbo.EngagementTasks ET ON ETM.TaskID = ET.TaskID
    WHERE 
        (@EngagementID IS NULL OR ETM.EngagementID = @EngagementID)
	Order By ET.TaskName
    

    -- Select team members related to engagement(s)
    SELECT 
        EUM.MappingID,
		 EUM.EngagementID, -- Added EngagementID
        EUM.UserID,
        U.DisplayName AS TeamMemberName,
        EUM.StartDate,
        EUM.EndDate,
        EUM.MaxWeeklyHours,
        EUM.CreatedBy,
        EUM.ModifiedBy,
        EUM.ModifiedOn,
        EUM.CreatedOn
    FROM 
        dbo.EngagementUserMapping EUM
    INNER JOIN 
        dbo.Users U ON EUM.UserID = U.UserID
    WHERE 
        (@EngagementID IS NULL OR EUM.EngagementID = @EngagementID);

	
	SELECT 
        EOM.MappingID,
        EOM.EngagementID,
        EOM.UserID,
        U.DisplayName AS OwnerName,
        EOM.CreatedBy,
        EOM.ModifiedBy,
        EOM.CreatedOn,
        EOM.ModifiedOn
    FROM 
        dbo.EngagementOwnersMapping EOM
    INNER JOIN 
        dbo.Users U ON EOM.UserID = U.UserID
    WHERE 
        (@EngagementID IS NULL OR EOM.EngagementID = @EngagementID);
    
END