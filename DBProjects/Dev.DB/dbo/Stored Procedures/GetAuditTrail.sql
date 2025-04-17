-- =============================================
-- Author:		<Author,,Kunal Mali>
-- Create date: <Create Date,,>
-- Description:	<This sp is used to get the data from the audit trail table,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAuditTrail]
    @TableId INT,
	@TableKey INT,
    @FieldName VARCHAR(50)
AS
BEGIN
    SELECT 
        LogId, 
        TableId, 
        TableName, 
        TableKey, 
        FieldName, 
        PreviousValue, 
        NewValue, 
        ModifiedBy, 
        ModifiedOn, 
        BatchId
    FROM AuditTrail WITH (NOlOCK)
    WHERE TableId = @TableId AND TableKey = @TableKey AND FieldName = @FieldName
    ORDER BY ModifiedOn DESC;
END