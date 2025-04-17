INSERT INTO Configuration (ID, UniqueId, Name, Description, Value, CreatedBy, ModifiedBy)
VALUES 
(1, '1001', 'Work Hours Per Day','Number of work hours in a day','9', 1, 1),
(2,'2001', 'Maximum Leaves Per Year', 'The maximum number of leave days allowed per year','20', 5, 5);

select * from Configuration