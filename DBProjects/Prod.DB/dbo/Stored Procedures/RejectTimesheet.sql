
CREATE PROCEDURE [dbo].[RejectTimesheet]
    @TimesheetID INT,
    @RejectionComment NVARCHAR(500),
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Update TimesheetHdr to set the status to 4 (rejected) and update ModifiedBy with ModUser
    UPDATE dbo.TimesheetHdr
    SET 
        Status = 4,
        ModifiedBy = @ModUser,
        ModifiedOn = GETDATE()
    WHERE TimesheetID = @TimesheetID;

    -- Check if the TimesheetHdr update was successful
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Timesheet not found or already rejected.', 16, 1);
        RETURN;
    END

    -- Step 2: Update TimesheetWorkflow with rejection details
    UPDATE dbo.TimesheetWorkflow
    SET 
        RejectionComment = @RejectionComment,
        RejectedBy = @ModUser,
        RejectedOn = GETDATE(),
        ModifiedBy = @ModUser,
        ModifiedOn = GETDATE()
    WHERE TimesheetID = @TimesheetID;

    -- Check if TimesheetWorkflow was updated; if not, raise an error
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Timesheet workflow entry not found.', 16, 1);
    END
END;
