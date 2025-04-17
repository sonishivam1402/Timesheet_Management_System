use UCITMSDev

INSERT INTO TimesheetLines
(TimesheetID, EngagementID, TaskID, Hours, Minutes, Date, Comment, CreatedBy, ModifiedBy, ModifiedOn, CreatedOn)
VALUES
( 1, 1, 1, 2, 00,'2024-10-10', 'Completed task 1', 1, 1, GETDATE(), GETDATE()),
( 1, 1, 2, 1, 30,'2024-10-10', 'Completed task 2', 1, 1, GETDATE(), GETDATE());

select * from TimesheetLines
