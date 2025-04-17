CREATE TABLE [dbo].[EngagementOwnersMapping] (
    [EngagementID] INT      NOT NULL,
    [UserID]       INT      NOT NULL,
    [CreatedBy]    INT      NULL,
    [ModifiedBy]   INT      NULL,
    [CreatedOn]    DATETIME DEFAULT (getdate()) NULL,
    [ModifiedOn]   DATETIME DEFAULT (getdate()) NULL,
    [MappingID]    INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_EngagementOwnersMapping] PRIMARY KEY CLUSTERED ([MappingID] ASC),
    CONSTRAINT [FK_EngagementOwners_Engagements] FOREIGN KEY ([EngagementID]) REFERENCES [dbo].[Engagements] ([EngagementID]),
    CONSTRAINT [FK_EngagementOwners_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);

