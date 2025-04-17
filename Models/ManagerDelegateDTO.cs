namespace UCITMS.Models
{
    #region Post Manager Delegate Info
    public class PostManagerDelegateDTO
    {
        public int? ManagerID { get; set; }
        public int? DelegateID {  get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int? ModUser { get; set; }

    }

    #endregion

    # region Get Manager Delegate Info 
    public class GetManagerDelegateDTO
    {
        public int ManagerID { get; set; }
        public int DelegateID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string ManagerName { get; set; }
        public string DelegateName { get; set; }
        public int ModifiedBy { get; set; }
        public string ModifiedByName { get; set; }
        public DateTime ModifiedOn { get; set; }
    }

    #endregion

    #region Get All Managers List

    public class GetAllManagersDTO
    {
        public int UserID { get; set; }
        public string UserName { get; set; }
    }

    #endregion 
}