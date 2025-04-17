
CREATE PROCEDURE [dbo].[AddOrUpdateDelegates]
@ManagerID INT,
@DelegateID INT,
@StartDate DATETIME,
@EndDate DATETIME,
@ModUser INT
AS 
BEGIN
	IF EXISTS ( SELECT 1 FROM [dbo].[ManagerDelegateMapping] WHERE ManagerID = @ManagerID )
		BEGIN
			UPDATE [dbo].[ManagerDelegateMapping] 
			SET DelegateID = @DelegateID
			,StartDate=@StartDate,
			EndDate=@EndDate
			, ModifiedOn = GETUTCDATE(), ModifiedBy = @ModUser WHERE ManagerID = @ManagerID;
		END
	ELSE 
		BEGIN
			INSERT INTO [dbo].[ManagerDelegateMapping]
	        (ManagerID,
			DelegateID,
			StartDate,
			EndDate,
			CreatedBy,
			CreatedOn,
			ModifiedBy,
			ModifiedOn) 
				VALUES
				(@ManagerID, 
				@DelegateID,
				@StartDate,
				@EndDate,
				@ModUser,
				GETUTCDATE(),
				@ModUser,
				GETUTCDATE());
			END
		END;