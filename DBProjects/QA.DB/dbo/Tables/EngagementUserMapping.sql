CREATE TABLE [dbo].[EngagementUserMapping] (
    [MappingID]      INT      IDENTITY (1, 1) NOT NULL,
    [EngagementID]   INT      NULL,
    [UserID]         INT      NULL,
    [StartDate]      DATE     NULL,
    [EndDate]        DATE     NULL,
    [MaxWeeklyHours] INT      DEFAULT ((0)) NULL,
    [CreatedBy]      INT      NULL,
    [ModifiedBy]     INT      NULL,
    [ModifiedOn]     DATETIME DEFAULT (getdate()) NULL,
    [CreatedOn]      DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([MappingID] ASC),
    CONSTRAINT [FK_EngagementID_Assignment] FOREIGN KEY ([EngagementID]) REFERENCES [dbo].[Engagements] ([EngagementID]),
    CONSTRAINT [FK_UserID_Assignment] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);

