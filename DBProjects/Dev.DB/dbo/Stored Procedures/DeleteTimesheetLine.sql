
CREATE   PROCEDURE [dbo].[DeleteTimesheetLine]
    @LineID INT
AS
BEGIN
    -- Check if the record exists
    IF EXISTS (SELECT 1 FROM TimesheetLines WHERE LineID = @LineID)
    BEGIN
        -- Delete the record
        DELETE FROM dbo.TimesheetLines WHERE LineID = @LineID;

        -- Return success message
        SELECT 'Record deleted successfully.' AS Message;
    END
    ELSE
    BEGIN
        -- Return a message indicating the record was not found
        SELECT 'Record not found.' AS Message;
    END
END
