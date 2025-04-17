

CREATE PROCEDURE [dbo].[GetEngagementsByUserID]
    @EngagementID INT = NULL, -- If NULL, it will return all engagements
    @CreatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Temporary table to store filtered engagements
    CREATE TABLE #FilteredEngagements
    (
        EngagementID INT
    );

    -- Select engagement details
    INSERT INTO #FilteredEngagements (EngagementID)
    SELECT 
        E.EngagementID
    FROM 
        Engagements E
    WHERE  (@CreatedBy IS NULL OR E.CreatedBy = @CreatedBy);

    -- Fetch engagement details with other fields
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
        Engagements E
    LEFT JOIN 
        Users U ON E.CreatedBy = U.UserID
    LEFT JOIN 
        Users U2 ON E.ModifiedBy = U2.UserID
    WHERE 
        E.EngagementID IN (SELECT EngagementID FROM #FilteredEngagements);

    -- Select tasks related to the filtered engagements
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
        EngagementTaskMapping ETM
    INNER JOIN 
        EngagementTasks ET ON ETM.TaskID = ET.TaskID
    WHERE 
        ETM.EngagementID IN (SELECT EngagementID FROM #FilteredEngagements);

    -- Select team members related to the filtered engagements
    SELECT 
        EUM.MappingID,
        EUM.EngagementID,
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
        EngagementUserMapping EUM
    INNER JOIN 
        Users U ON EUM.UserID = U.UserID
    WHERE 
        EUM.EngagementID IN (SELECT EngagementID FROM #FilteredEngagements);

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
        EngagementOwnersMapping EOM
    INNER JOIN 
        Users U ON EOM.UserID = U.UserID
	WHERE 
        EOM.EngagementID IN (SELECT EngagementID FROM #FilteredEngagements);

    -- Clean up the temporary table
    DROP TABLE #FilteredEngagements;
    
END
