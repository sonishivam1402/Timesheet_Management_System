CREATE FUNCTION [dbo].[fnApprovedOrRejectedTsDescription] 
(
    @Template NVARCHAR(255),
    @Duration NVARCHAR(50),
    @ManagerName NVARCHAR(100)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @Result NVARCHAR(255);

    -- Replace placeholders with actual values
    SET @Result = REPLACE(@Template, '[duration]', @Duration);
    SET @Result = REPLACE(@Result, '[managername]', @ManagerName);

    RETURN @Result;
END;