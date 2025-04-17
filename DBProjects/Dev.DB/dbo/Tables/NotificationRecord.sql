CREATE TABLE [dbo].[NotificationRecord] (
    [RecordId]       INT           IDENTITY (1, 1) NOT NULL,
    [UserId]         INT           NOT NULL,
    [NotificationId] INT           NOT NULL,
    [Description]    VARCHAR (255) NULL,
    [IsRead]         BIT           DEFAULT ((0)) NOT NULL,
    [IsActive]       BIT           DEFAULT ((1)) NOT NULL,
    [CreatedBy]      INT           NOT NULL,
    [CreatedOn]      DATETIME      DEFAULT (getutcdate()) NOT NULL,
    [ModifiedBy]     INT           NOT NULL,
    [ModifiedOn]     DATETIME      DEFAULT (getutcdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([RecordId] ASC),
    CONSTRAINT [FK_NotificationRecord_NotificationMaster] FOREIGN KEY ([NotificationId]) REFERENCES [dbo].[NotificationMaster] ([NotificationID]),
    CONSTRAINT [FK_NotificationRecord_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserID])
);

