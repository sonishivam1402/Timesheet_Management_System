using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface ISuperUserRepository
    {
        Task<List<SuperUserDTO>> GetSuperUserInfo();
    }
}
