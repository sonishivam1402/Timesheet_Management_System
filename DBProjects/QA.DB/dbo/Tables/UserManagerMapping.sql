CREATE TABLE [dbo].[UserManagerMapping] (
    [MappingID]   INT      IDENTITY (1, 1) NOT NULL,
    [ManagerID]   INT      NULL,
    [UserID]      INT      NULL,
    [isPrimary]   BIT      DEFAULT ((1)) NULL,
    [isSecondary] BIT      DEFAULT ((0)) NULL,
    [CreatedBy]   INT      NULL,
    [ModifiedBy]  INT      NULL,
    [ModifiedOn]  DATETIME DEFAULT (getdate()) NULL,
    [CreatedOn]   DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([MappingID] ASC),
    CONSTRAINT [FK_ManagerID] FOREIGN KEY ([ManagerID]) REFERENCES [dbo].[Users] ([UserID]),
    CONSTRAINT [FK_UserID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);

