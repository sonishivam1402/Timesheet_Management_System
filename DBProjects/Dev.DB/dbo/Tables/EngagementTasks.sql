CREATE TABLE [dbo].[EngagementTasks] (
    [TaskID]          INT            IDENTITY (1, 1) NOT NULL,
    [TaskName]        NVARCHAR (200) NULL,
    [TaskDescription] NVARCHAR (500) NULL,
    [IsDeleted]       BIT            DEFAULT ((0)) NULL,
    [IsGeneric]       BIT            NULL,
    [CreatedBy]       INT            NULL,
    [ModifiedBy]      INT            NULL,
    [ModifiedOn]      DATETIME       DEFAULT (getdate()) NULL,
    [CreatedOn]       DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([TaskID] ASC),
    CONSTRAINT [FK_CreatedBy_Tasks] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserID]),
    CONSTRAINT [FK_ModifiedBy_Tasks] FOREIGN KEY ([ModifiedBy]) REFERENCES [dbo].[Users] ([UserID])
);

