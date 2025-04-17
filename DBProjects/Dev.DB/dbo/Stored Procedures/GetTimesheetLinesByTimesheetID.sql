
Create PROCEDURE [dbo].[GetTimesheetLinesByTimesheetID]
    @TimesheetID INT
AS
BEGIN
    -- Select timesheet lines where the TimesheetID matches the provided parameter, 
    -- including EngagementName and TaskName from the related tables
    SELECT 
        tl.[LineID],
        tl.[TimesheetID],
        tl.[EngagementID],
        e.[Title] AS EngagementName,
        tl.[TaskID],
        et.[TaskName] AS TaskName,
        tl.[Hours],
        tl.[Minutes],
        tl.[Date],
        tl.[Comment],
        tl.[CreatedBy],
        tl.[ModifiedBy],
        tl.[ModifiedOn],
        tl.[CreatedOn]
    FROM 
        [dbo].[TimesheetLines] AS tl
    LEFT JOIN 
        [dbo].[Engagements] AS e ON tl.EngagementID = e.EngagementID
    LEFT JOIN 
        [dbo].[EngagementTasks] AS et ON tl.TaskID = et.TaskID
    WHERE 
        tl.[TimesheetID] = @TimesheetID;
END
