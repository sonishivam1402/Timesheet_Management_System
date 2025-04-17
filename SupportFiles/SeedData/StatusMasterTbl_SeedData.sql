use UCITMSDev

INSERT INTO StatusMaster (StatusId, StatusName,IsActive, CreatedBy, ModifiedBy)
VALUES 
	(1, 'Submitted',1, 1, 1),
	(2, 'Approved',0, 1, 1),
	(3, 'Rejected',1, 1, 1);

select * from StatusMaster