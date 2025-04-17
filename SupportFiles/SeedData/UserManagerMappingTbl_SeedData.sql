INSERT INTO UserManagerMapping
(ManagerID, UserID, isPrimary, isSecondary, CreatedBy, ModifiedBy, ModifiedOn, CreatedOn)
VALUES
( 1, 1, 1, 0, 1, 1, GETDATE(), GETDATE()),
( 4, 4, 1, 0, 5, 5, GETDATE(), GETDATE());

select * from UserManagerMapping