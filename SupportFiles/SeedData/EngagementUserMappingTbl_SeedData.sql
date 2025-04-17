INSERT INTO [dbo].[EngagementUserMapping] 
(EngagementID, UserID, StartDate, EndDate, MaxWeeklyHours, CreatedBy, ModifiedBy)
VALUES
(1, 1, '2024-10-01', '2024-12-31', 40, 1001, 1001), 
(2, 4, '2024-10-05', '2024-11-30', 35, 1002, 1002);

select * from [dbo].[EngagementUserMapping]