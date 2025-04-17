USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnApprovedOrRejectedTsDescription]    Script Date: 02-12-2024 21:40:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
GO

