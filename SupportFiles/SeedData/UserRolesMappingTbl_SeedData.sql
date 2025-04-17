INSERT INTO UserRolesMapping
( UserID, RoleID, CreatedBy, ModifiedBy, ModifiedOn, CreatedOn)
VALUES
( 1, 1, 1, 1, GETDATE(), GETDATE()),
( 4, 2, 5, 5, GETDATE(), GETDATE());

select * from UserRolesMapping
