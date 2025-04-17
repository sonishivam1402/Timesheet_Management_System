INSERT INTO Menu (MenuName, ImagePath, NavigationPath, NavigationType, SortOrder, IsActive, CreatedBy, ModifiedBy)
VALUES 
('HR Admin Dashboard', 'bars icon', '/HR/Index', 'HR Sub', 1, 1, 1, 1),
('Approval Status', 'file alternate icon', '/HR/Index', 'HR Sub', 2, 1, 5, 6),
('Assign Approver', 'users icon', '/HR/Index', 'HR Sub', 3, 1, 1, 1),
('Engagement Status', 'tasks icon', '/HR/Index', 'HR Sub', 4, 1, 5, 6);


INSERT INTO Menu (MenuName, ImagePath, NavigationPath, NavigationType, SortOrder, IsActive, CreatedBy, ModifiedBy)
VALUES 
('Manager Dashboard', 'bars icon', '/Manager/Index', 'Manager Sub', 1, 1, 1, 1),
('Pending Approval', 'file alternate icon', '/Manager/Index', 'Manager Sub', 2, 1, 6, 6),
('Approved Timesheets', 'users icon', '/Manager/Index', 'Manager Sub', 3, 1, 4, 4),
('Manage My Engagements', 'tasks icon', '/Manager/Index', 'Manager Sub', 4, 1, 5, 5);

INSERT INTO Menu (MenuName, ImagePath, NavigationPath, NavigationType, SortOrder, IsActive, CreatedBy, ModifiedBy)
VALUES
('Employee Dashboard', 'bars icon', '/Employee/Index', 'Employee Sub', 1, 1, 1, 1),
('Add new Timesheet', 'file alternate icon', '/Employee/Index', 'Employee Sub', 2, 1, 6, 6),
('View Previous Timesheets', 'users icon', '/Employee/Index', 'Employee Sub', 3, 1, 4, 4),
('My Engagements', 'tasks icon', '/Employee/Index', 'Employee Sub', 4, 1, 5, 5);

