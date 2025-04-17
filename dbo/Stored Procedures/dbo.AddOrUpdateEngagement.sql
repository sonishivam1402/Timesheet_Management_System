USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[AddOrUpdateEngagement]    Script Date: 26-12-2024 18:02:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AddOrUpdateEngagement]
    @EngagementID INT,
    @Title NVARCHAR(200),
    @StartDate DATE,
    @EndDate DATE,
    @Description NVARCHAR(MAX),
    @ModUser INT,
    @TeamMembers dbo.TeamMemberType READONLY,
    @Tasks dbo.TaskType READONLY,
    @EngagementOwners dbo.EngagementOwnerType READONLY
AS
BEGIN
    SET NOCOUNT ON;

	-- Validate engagement
    IF dbo.fnValidateEngagement(@ModUser, @EngagementOwners, @TeamMembers) = 0
    BEGIN
        RAISERROR('Validation failed: ModUser must be an owner and all owners must be team members.', 16, 1);
        RETURN;
    END

	-- Validate dates for engagements and team members
	if dbo.fnValidateDateInEngagement(@StartDate, @EndDate, @TeamMembers) = 0 
	begin
		raiserror('Date validation failed', 16, 1);
		return;
	end

    -- Declare variable to capture EngagementID
    DECLARE @NewEngagementID INT;

    -- Check if EngagementID is provided (for update)
    IF @EngagementID = 0
    BEGIN
        -- Insert new engagement
        INSERT INTO [dbo].[Engagements]
        (
            Title, StartDate, EndDate, Description, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn, EngagementCategoryID, EngagementScopeID
        )
        VALUES
        (
            @Title, @StartDate, @EndDate, @Description, @ModUser, @ModUser, GETUTCDATE(), GETUTCDATE(), 1, 1
        );

        -- Capture the new EngagementID
        SET @NewEngagementID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        -- Update existing engagement
        UPDATE [dbo].[Engagements]
        SET Title = @Title,
            StartDate = @StartDate,
            EndDate = @EndDate,
            Description = @Description,
            ModifiedBy = @ModUser,
            ModifiedOn = GETUTCDATE(),
            EngagementCategoryID = 1
        WHERE EngagementID = @EngagementID;

        -- Use the provided EngagementID
        SET @NewEngagementID = @EngagementID;
    END

    -- Call child procedures for team members, tasks, and owners
    EXEC dbo.AddOrUpdateTeamMembers @NewEngagementID, @TeamMembers, @ModUser;
    EXEC dbo.AddOrUpdateTasks @NewEngagementID, @Tasks, @ModUser;
    EXEC dbo.AddOrUpdateOwners @NewEngagementID, @EngagementOwners, @ModUser;

    -- Return the EngagementID
    SELECT @NewEngagementID AS EngagementID;
END;
GO

