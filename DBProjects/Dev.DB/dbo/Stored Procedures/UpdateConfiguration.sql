CREATE PROCEDURE [dbo].[UpdateConfiguration] 
    @ID INT,
    @Value NVARCHAR(MAX),
    @ModifiedBy INT
AS
BEGIN
    UPDATE dbo.Configuration
    SET  
        Value = @Value, 
        ModifiedBy = @ModifiedBy,
        ModifiedOn = GETUTCDATE() 
    WHERE ID = @ID;
END