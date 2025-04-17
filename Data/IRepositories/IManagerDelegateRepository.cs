using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IManagerDelegateRepository
    {
        #region Get Manager Delegate

        Task<List<GetManagerDelegateDTO>> GetManagerDelegateInfoAsync();
        #endregion

        #region Add or Update Delegate

        Task<string> AddOrUpdateDelegatesAsync(PostManagerDelegateDTO managerdelegate);

        #endregion

        #region Get All Managers List

        Task<List<GetAllManagersDTO>> GetAllManagersInfoAsync();

        #endregion
    }
}
