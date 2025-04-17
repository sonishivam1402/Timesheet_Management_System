using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IDashboardRepository
    {
        #region Employee Dashboard
        Task<GetEmpDashboardDTO> GetLastTSDateAndDefaultsAsync(int? id);
        Task<GetUserManagerDTO> GetUserApproverInfoAsync(int? id);
        Task<List<GetEmpDefaultsDTO>> GetEmployeeDefaults(int? userId);

        #endregion

        #region Manager Dashboard
        Task<GetPendingApprovalCountDTO> GetPendingApprovalCountAsync(int? id);
        Task<List<GetManagedUsersDTO>> GetAllManagedUsersAsync(int? id);
        Task<GetDelegateTimeSpanDTO> GetDelegateTimeSpanInfoAsync(int? id);
        Task<GetManagerDelegateDTO> GetDelegateInfoAsync(int? id);
        Task<List<GetManagerDefaulterDTO>> GetManagerDefaulterInfoAsync(int? id);   

        #endregion

        #region HR Dashboard
        Task<GetDefaulterCountDTO> GetTotalDefaultersAsync();

        Task<UsersNoApproverCountDTO> GetCountNoApproverAsync();
        #endregion
    }
}
