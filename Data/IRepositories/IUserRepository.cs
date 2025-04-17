using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IUserRepository
    {
        #region Get All Users
        Task<List<UserDTO>> GetAllUsers();
        #endregion
    }
}
