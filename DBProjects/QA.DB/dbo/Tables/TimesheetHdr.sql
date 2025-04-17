CREATE TABLE [dbo].[TimesheetHdr] (
    [TimesheetID]  INT      IDENTITY (1, 1) NOT NULL,
    [UserID]       INT      NULL,
    [StartDate]    DATE     NULL,
    [EndDate]      DATE     NULL,
    [Status]       INT      NULL,
    [DaysCount]    INT      NULL,
    [HoursTotal]   INT      NULL,
    [MinutesTotal] INT      NULL,
    [CreatedBy]    INT      NULL,
    [ModifiedBy]   INT      NULL,
    [ModifiedOn]   DATETIME DEFAULT (getdate()) NULL,
    [CreatedOn]    DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([TimesheetID] ASC),
    CONSTRAINT [FK_UserID_TimesheetHdr] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);

