-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Kunal Mali,,Name>
-- Create date: <Create Date,,>
-- Description:	<This sp is used to update the engagement scope with mod on/by,,>
-- =============================================
ALTER PROCEDURE [dbo].[UpdateEngagementScope]
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
GO
