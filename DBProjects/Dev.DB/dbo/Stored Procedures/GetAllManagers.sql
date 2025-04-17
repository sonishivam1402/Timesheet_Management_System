CREATE PROCEDURE [dbo].[GetAllManagers]
AS
BEGIN
    -- Retrieve distinct managers using the vwManagers view
    SELECT DISTINCT 
        M.UserId AS ManagerId,
        M.DisplayName AS ManagerName
    FROM 
        [dbo].[vwManagers] M
    ORDER BY 
        M.DisplayName; -- Optionally order by manager name
END