using UCITMS.ViewModels;

namespace UCITMS.Data.IRepositories
{
    public interface IMenuRepository
    {
        #region Get Users Menu by ID
        Task<List<VMMenu>> GetUserMenuById(int userId);

        #endregion

        Task<int> GetDefaultMenuIdByUserId(int userId);
    }
}
