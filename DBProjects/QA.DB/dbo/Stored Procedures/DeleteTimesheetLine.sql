

CREATE   PROCEDURE [dbo].[DeleteTimesheetLine]
    @LineID INT
AS
BEGIN

declare @TimesheetId int
select @TimesheetId=TimesheetId From dbo.TimesheetLines where LineId=@LineId
declare @hasAccess bit=0
if not exists (
			
			select 1 from dbo.Timesheethdr T with (NoLock) where T.TimesheetId=@TimesheetId 
			and T.Status in(1,4)
			)
	begin
		return
	end



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