namespace UCITMS.Models
{
    #region Get Admin Dashboard Info
    public class GetAdminDashboardInfoDTO
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string Key { get; set; }
        public int Value { get; set; }
    }

    #endregion

    #region Get System User Info

    public class GetSystemUserDTO
    {
        public int UserID { get; set; }
        public string DisplayName { get; set; }
        public string Email { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public bool IsActive { get; set; }
        public string EmployeeID { get; set; }
        public int? LocationID { get; set; }
        public string LocationName { get; set; }
        public int? DepartmentID { get; set; }

        public string DepartmentName { get; set; }

        public List<int> UserRoles { get; set; }

        public List<string> UserRoleName { get; set; }
    }


    #endregion

    #region Post System User Info

    public class PostSystemUserDTO
    {
        public int UserID { get; set; }
        public bool IsActive { get; set; }
        public string EmployeeID { get; set; }
        public int LocationID { get; set; }
        public int DepartmentID { get; set; }

        public string Roles { get; set; }
        public int? ModUser {  get; set; }
    }

    #endregion
}
