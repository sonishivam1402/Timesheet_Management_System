using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IUserInfoRepository
    {
        #region Get User by Email
        UserDTO GetuserbyEmail(string Email);

        #endregion

        //List<int> GetRolesbyuserID(int id);
    }
}
