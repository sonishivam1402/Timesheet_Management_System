using UCITMS.Common;
using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IAuthorizationRepository
    {
        #region Check if User is Authorized
        bool isAuthorized(int autherizationTypeId,int Itemid,int CurrentUserId);
        #endregion
        #region Check Timesheet Access
        bool TimesheetAccess(AutherizationType autherizationTypeId, int TimeSheetId, int CurrentUserId);
        #endregion
    }
}
