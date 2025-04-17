CREATE TABLE [dbo].[NotifiedEmailLogs] (
    [LogId]       INT      IDENTITY (1, 1) NOT NULL,
    [SentOn]      DATETIME NULL,
    [UserID]      INT      NULL,
    [ManagerID]   INT      NULL,
    [TimesheetID] INT      NULL,
    CONSTRAINT [FK_Manager] FOREIGN KEY ([ManagerID]) REFERENCES [dbo].[Users] ([UserID]),
    CONSTRAINT [FK_Timesheet] FOREIGN KEY ([TimesheetID]) REFERENCES [dbo].[TimesheetHdr] ([TimesheetID]),
    CONSTRAINT [FK_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);

