CREATE PROCEDURE [dbo].[ManageDelegateRole]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the UserID is present in DelegateID column
    IF EXISTS (SELECT 1 FROM ManagerDelegateMapping WHERE DelegateID = @UserID)
    BEGIN
        DECLARE @StartDate DATETIME, @EndDate DATETIME;

		-- Fetch the smallest StartDate and biggest EndDate for the UserID
		SELECT 
		    @StartDate = MIN(StartDate), 
		    @EndDate = MAX(EndDate)
		FROM ManagerDelegateMapping
		WHERE DelegateID = @UserID;

        -- Case 1: Current date falls between StartDate and EndDate
        IF GETUTCDATE() BETWEEN @StartDate AND @EndDate
        BEGIN
            -- Add a row in UserRolesMapping for RoleID = 5 only if it does not exist
            IF NOT EXISTS (SELECT 1 FROM UserRolesMapping WHERE UserID = @UserID AND RoleID = 5)
            BEGIN
                -- Insert a new row for RoleID = 5
                INSERT INTO UserRolesMapping (UserID, RoleID, CreatedOn, ModifiedOn)
                VALUES (@UserID, 5, GETUTCDATE(), GETUTCDATE());
            END
        END
        -- Case 2: Current date is before StartDate
        ELSE IF GETUTCDATE() < @StartDate
        BEGIN
            -- Delete the row in UserRolesMapping if it exists for RoleID = 5
            DELETE FROM UserRolesMapping
            WHERE UserID = @UserID AND RoleID = 5;
        END
        -- Case 3: Current date is after EndDate
        ELSE IF GETUTCDATE() > @EndDate
        BEGIN
            -- Delete the row from ManagerDelegateMapping
            DELETE FROM ManagerDelegateMapping
            WHERE DelegateID = @UserID;

            -- Delete the row in UserRolesMapping if it exists for RoleID = 5
            DELETE FROM UserRolesMapping
            WHERE UserID = @UserID AND RoleID = 5;
        END
    END
END;