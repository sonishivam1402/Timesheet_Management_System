
-- Calculate next timesheet dates
CREATE PROCEDURE [dbo].[CalculateNextTimesheetDates]
    @EndDate DATE,
    @NextMonday DATE OUTPUT,
    @NextFriday DATE OUTPUT
AS
BEGIN
    SET @NextMonday = DATEADD(DAY, (8 - DATEPART(WEEKDAY, @EndDate)) % 7 + 1, @EndDate);
    SET @NextFriday = DATEADD(DAY, 4, @NextMonday);
END;
