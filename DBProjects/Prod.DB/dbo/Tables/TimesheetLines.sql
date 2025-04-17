CREATE TABLE [dbo].[TimesheetLines] (
    [LineID]       INT            IDENTITY (1, 1) NOT NULL,
    [TimesheetID]  INT            NULL,
    [EngagementID] INT            NULL,
    [TaskID]       INT            NULL,
    [Hours]        INT            NULL,
    [Minutes]      INT            NULL,
    [Date]         DATE           NULL,
    [Comment]      NVARCHAR (500) NULL,
    [CreatedBy]    INT            NULL,
    [ModifiedBy]   INT            NULL,
    [ModifiedOn]   DATETIME       NULL,
    [CreatedOn]    DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([LineID] ASC),
    CONSTRAINT [FK_TimesheetID_TimesheetLines] FOREIGN KEY ([TimesheetID]) REFERENCES [dbo].[TimesheetHdr] ([TimesheetID])
);

