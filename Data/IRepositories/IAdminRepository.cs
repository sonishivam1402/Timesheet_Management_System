using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IAdminRepository
    {
        #region Get Admin Dashboard Info
        Task<List<GetAdminDashboardInfoDTO>> GetDashboardInfoAsync();

        #endregion

        #region Get System User Info

        Task<List<GetSystemUserDTO>> GetAllSystemUsersAsync();

        #endregion

        #region Post System User Info

        Task<string> UpdateSystemUserAsync(PostSystemUserDTO user);

        #endregion

        #region Get engagements for admin
        Task<List<GetEngagementForAdminDTO>> GetEngagementsForAdmin();
        #endregion

        #region Update the engagement scope 
        Task<bool> UpdateEngagementScope(PostEngagementForAdminDTO engagement);
        #endregion
    }
}
