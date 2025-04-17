

CREATE PROCEDURE [dbo].[UpdateSystemUser]
    @UserID INT,
    @IsActive BIT,
	@EmployeeID NVARCHAR(100),
    @Location INT,
    @Department INT,
	@NewRoles NVARCHAR(100),
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
	
	-- Update the user record
    UPDATE [dbo].[Users]
    SET 
		IsActive = @IsActive,
		EmployeeID = @EmployeeID,
        Location = @Location,
        Department = @Department,
        ModifiedBy = @ModifiedBy,
        ModifiedOn = GETUTCDATE() 
     WHERE 
        UserID = @UserID;	   
		
		EXEC [dbo].[UpdateUserRoles]
        @NewRoles = @NewRoles,
        @UserId = @UserID,
        @ModUser = @ModifiedBy;
END;