
---GET ALL MANGERS IN APPLICATIONS ---
select * From 
dbo.vwUserRoles V where 
(Select count(1) from string_split(V.RoleIds,',') where Value='2')<>0


---GET ALL Admin IN APPLICATIONS ---
select * From 
dbo.vwUserRoles V where 
(Select count(1) from string_split(V.RoleIds,',') where Value='4')<>0


---GET ALL HR IN APPLICATIONS ---
select * From 
dbo.vwUserRoles V where 
(Select count(1) from string_split(V.RoleIds,',') where Value='1')<>0

--All Users who are in Multiple Roles
select * From dbo.vwUserRoles where RoleCount<>1


---Get All the Role Mapping in the application
select * From dbo.vwRoleMapping 