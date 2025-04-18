USE [UCITMSDev]
GO
/****** Object:  StoredProcedure [UserTMSDev].[GetAuditTrail]    Script Date: 29-11-2024 15:23:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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