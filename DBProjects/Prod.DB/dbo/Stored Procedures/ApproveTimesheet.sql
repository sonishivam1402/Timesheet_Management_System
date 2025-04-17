CREATE PROCEDURE [dbo].[ApproveTimesheet]
    @TimesheetID INT,
    @ApprovalComment NVARCHAR(500),
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Update TimesheetHdr to set the status to 3 (approved) and update ModifiedBy with ModUser
    UPDATE dbo.TimesheetHdr
    SET 
        Status = 3,
        ModifiedBy = @ModUser,
        ModifiedOn = GETUTCDATE()
    WHERE TimesheetID = @TimesheetID;

    -- Check if the TimesheetHdr update was successful
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Timesheet not found or already approved.', 16, 1);
        RETURN;
    END

    -- Step 2: Update TimesheetWorkflow with approval details
    UPDATE dbo.TimesheetWorkflow
    SET 
        ApprovalComment = @ApprovalComment,
        ApprovedBy = @ModUser,
        ApprovedOn = GETUTCDATE(),
        ModifiedBy = @ModUser,
        ModifiedOn = GETUTCDATE()
    WHERE TimesheetID = @TimesheetID;

    -- Check if TimesheetWorkflow was updated; if not, raise an error
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Timesheet workflow entry not found.', 16, 1);
    END
END;
