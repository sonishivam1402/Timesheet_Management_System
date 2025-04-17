-- =============================================
-- Author:		<Kunal Mali,,Name>
-- Create date: <Create Date,,>
-- Description:	<This sp is used to update the engagement scope with mod on/by,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEngagementScope]
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