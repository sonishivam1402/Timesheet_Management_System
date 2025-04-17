CREATE TABLE [dbo].[NotificationMaster] (
    [NotificationID] INT           NOT NULL,
    [Template]       VARCHAR (255) NULL,
    [Icon]           VARCHAR (80)  NULL,
    [IsActive]       BIT           DEFAULT ((1)) NOT NULL,
    [CreatedBy]      INT           NULL,
    [CreatedOn]      DATE          DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]     INT           NULL,
    [ModifiedOn]     DATE          DEFAULT (getdate()) NOT NULL,
    [Title]          VARCHAR (150) NULL,
    PRIMARY KEY CLUSTERED ([NotificationID] ASC)
);

