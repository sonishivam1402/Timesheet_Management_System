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

    -- Declare variable to capture EngagementID
    DECLARE @NewEngagementID INT;

    -- Check if EngagementID is provided (for update)
    IF @EngagementID = 0
    BEGIN
        -- Insert new engagement
        INSERT INTO [dbo].[Engagements]
        (
            Title, StartDate, EndDate, Description, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn, EngagementCategoryID
        )
        VALUES
        (
            @Title, @StartDate, @EndDate, @Description, @ModUser, @ModUser, GETUTCDATE(), GETUTCDATE(), 1
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
