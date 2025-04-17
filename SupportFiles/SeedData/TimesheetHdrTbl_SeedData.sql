INSERT INTO TimesheetHdr
( UserID, StartDate, EndDate, Status, DaysCount, HoursTotal, MinutesTotal, CreatedBy, ModifiedBy, ModifiedOn, CreatedOn)
VALUES
( 1, '2024-10-01', '2024-10-07', 1, 5, 45, 2700, 1, 1, GETDATE(), GETDATE()),
( 4, '2024-10-01', '2024-10-07', 2, 5, 45, 2700, 4, 4, GETDATE(), GETDATE());

select * from TimesheetHdr