use UCITMSDev

INSERT INTO TimesheetWorkflow (
    WorkflowId, TimesheetID, SubmittedBy, SubmissionComment, ApprovedBy, ApprovalComment, RejectedBy, RejectionComment, CreatedBy, ModifiedBy
)
VALUES
    (1, 1, 1, 'Week 1 TimeSheet Submission', 5, 'Approved', 0, 'NULL', 1, 1),
	(2, 2, 6, 'Week 2 TimeSheet Submission', 0, 'NULL', 5, 'Rejected', 1, 1);

select * from TimesheetWorkflow
