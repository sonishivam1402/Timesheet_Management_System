CREATE TABLE [dbo].[Users] (
    [UserID]             INT            IDENTITY (1, 1) NOT NULL,
    [DisplayName]        NVARCHAR (100) NOT NULL,
    [Email]              NVARCHAR (100) NOT NULL,
    [CreatedBy]          INT            NULL,
    [ModifiedBy]         INT            NULL,
    [ModifiedOn]         DATETIME       DEFAULT (getdate()) NULL,
    [CreatedOn]          DATETIME       DEFAULT (getdate()) NULL,
    [IsActive]           BIT            CONSTRAINT [DF_Users_IsActive] DEFAULT ((1)) NULL,
    [EmployeeID]         VARCHAR (100)  NULL,
    [Location]           INT            NULL,
    [Department]         INT            NULL,
    [TimesheetStartDate] DATE           NULL,
    PRIMARY KEY CLUSTERED ([UserID] ASC)
);

