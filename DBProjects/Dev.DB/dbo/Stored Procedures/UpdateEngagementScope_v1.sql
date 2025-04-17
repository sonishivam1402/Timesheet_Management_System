-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEngagementScope_v1]
    @EngagementID INT,
    @NewEngagementScopeID INT,
	@ModifiedBy INT
AS
BEGIN
    UPDATE Engagements
    SET 
		EngagementScopeID = @NewEngagementScopeID,
		ModifiedOn = GETUTCDATE(),
		ModifiedBy = @ModifiedBy

    WHERE EngagementID = @EngagementID
END