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
-- Description:	<This sp is used to get all the active tasks that are not deleted from EngagementTasks table,,>
-- =============================================
CREATE PROCEDURE dbo.GetTasks
AS
BEGIN
    SELECT * FROM EngagementTasks WHERE IsDeleted = 0;
END;
GO
