CREATE TABLE [dbo].[TimesheetWorkflow] (
    [WorkflowId]             INT            IDENTITY (1, 1) NOT NULL,
    [TimesheetID]            INT            NULL,
    [SubmittedOn]            DATETIME       DEFAULT (getdate()) NULL,
    [SubmittedBy]            INT            NULL,
    [SubmissionComment]      NVARCHAR (500) NULL,
    [ApprovedOn]             DATETIME       NULL,
    [ApprovedBy]             INT            NULL,
    [ApprovalComment]        NVARCHAR (500) NULL,
    [RejectedOn]             DATETIME       NULL,
    [RejectedBy]             INT            NULL,
    [RejectionComment]       NVARCHAR (500) NULL,
    [CreatedBy]              INT            NULL,
    [ModifiedBy]             INT            NULL,
    [ModifiedOn]             DATETIME       DEFAULT (getdate()) NULL,
    [CreatedOn]              DATETIME       DEFAULT (getdate()) NULL,
    [SubmitNotificationSent] BIT            DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([WorkflowId] ASC),
    CONSTRAINT [FK_TimesheetID_TimesheetWorkflow] FOREIGN KEY ([TimesheetID]) REFERENCES [dbo].[TimesheetHdr] ([TimesheetID])
);

