using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IEngagementRepository
    {
        #region Save Engagement
        Task<int> SaveEngagementAsync(PostEngagementDTO engagement);
        #endregion

        #region Get Engagements
        Task<List<GetEngagementDTO>> GetAllEngagements();
        #endregion

        #region Get Engagements by Engagement ID

        GetEngagementDTO GetEngagementById(int engagementId);

        #endregion

        #region Get Engagements by UserID

        Task<List<GetEngagementDTO>> GetEngagementsByUserIdAsync(int? userId);

        #endregion

        #region Get Engagements by User and Date

        List<GetEngagementDTO> GetEngagementsByUserAndDate(int userId, DateTime date);

        #endregion

        #region Get Engagements for Employees
        Task<IEnumerable<GetAllEngagementsDTO>> GetEngagementsforEmployeeAsync(int? id);
        #endregion

        #region Get Tasks by Engagement Id

        List<GetTaskDTO> GetTasksByEngagementId(int engagementId);

        #endregion

        #region Delete engagement
        DeleteEngagementResponse DeleteEngagement(int engagementId, int userId);
        #endregion
    }
}
