namespace UCITMS.Models
{
    #region For Employee Dashboard
    public class GetEmpDashboardDTO
    {
        public string? LastTSDate { get; set; }
    }
    #endregion

    #region For Manager Dashboard

        #region Pending Approval Count
        public class GetPendingApprovalCountDTO
        {
            public int PendingApprovals { get; set; }
        }
        #endregion

        #region Managed Users
        public class GetManagedUsersDTO
        {
            public int UserID { get; set; }
            public string Username { get; set; }
            public bool IsPrimary { get; set; }
            public bool IsSecondary { get; set; }

        }
        #endregion

        #region Delegate Timespan
    public class GetDelegateTimeSpanDTO
    {
        public string? DelegateTimeSpan { get; set; }
    }
    #endregion

    #region Manager Defualter

    public class GetManagerDefaulterDTO
    {
        public int ManagerId { get; set; }
        public int? UserId { get; set; }
        public string Manager { get; set; }
        public string? User { get; set; }
        public string? Duration { get; set; }
        public DateTime? StartDate { get; set; }
        public bool? hasDraft { get; set; }
        public bool? hasSubmitted { get; set; }
        public bool? hasDefaulted { get; set; }
    
    }

    #endregion 

    #endregion

    #region For HR Dashboard

    #region Get Defaulter Count
    public class GetDefaulterCountDTO
        {
            public int DefaultersCount { get; set; }
        }
    #endregion

        #region Get Missing Approver Count
        public class UsersNoApproverCountDTO
        {
            public int? NoApproverCount { get; set; }
            public int? NoSecApproverCount { get; set; }

        }
    #endregion

    #endregion

    #region Get employee defaults
    public class GetEmpDefaultsDTO
    {
        public string? TimesheetDuration { get; set; }
    }
    #endregion
}
