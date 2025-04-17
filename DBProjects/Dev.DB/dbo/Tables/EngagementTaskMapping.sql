CREATE TABLE [dbo].[EngagementTaskMapping] (
    [EngagementTaskID] INT      IDENTITY (1, 1) NOT NULL,
    [EngagementID]     INT      NULL,
    [TaskID]           INT      NULL,
    [CreatedBy]        INT      NULL,
    [ModifiedBy]       INT      NULL,
    [ModifiedOn]       DATETIME DEFAULT (getdate()) NULL,
    [CreatedOn]        DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([EngagementTaskID] ASC),
    CONSTRAINT [FK_EngagementID_EngagementTask] FOREIGN KEY ([EngagementID]) REFERENCES [dbo].[Engagements] ([EngagementID])
);

