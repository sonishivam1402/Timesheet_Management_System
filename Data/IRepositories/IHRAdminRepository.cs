using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IHRAdminRepository
    {
        Task<List<UsersListDTO>> GetAllUsers();

        #region Get User Manager
        Task<List<GetUserManagerDTO>> GetUserManagerInfoAsync();
        #endregion

        #region Add or Update Approver

        Task<ValidateApproverDTO> AddOrUpdateApproversAsync(PostUserManagerDTO usermanager);

        #endregion

        #region Get User List with No Approver
        Task<List<UsersNoApproverListDTO>> GetListNoApproverAsync();
        #endregion

        bool SaveNotifiedEmailLog(NotifiedEmailLog model);  //post

        Task<List<NotifiedEmailLogAsync>> GetNotifiedDataAsync();   //get
    }
}
