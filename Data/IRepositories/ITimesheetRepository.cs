using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface ITimesheetRepository
    {
        #region Get Timesheet Data
        Task<GetTimesheetHdrDTO> GetTimesheetData(int userId);
        #endregion

        #region Add or Update TimesheetLine
        Task<int> AddOrUpdateTimesheetLineAsync(PostTimesheetLineDTO timesheetEntry);
        #endregion

        #region Delete Timesheet Line

        Task<string> DeleteTimesheetLineAsync(int lineID);

        #endregion

        #region Submit Timesheet for Approval
        Task<string> SubmitTimesheetForApprovalAsync(PostTimesheetHdrDTO timesheetHdr);
        #endregion

        #region Approve Timesheet
        Task<int> ApproveTimesheetAsync(PostApproveTimesheetDTO timesheetApproval);
        #endregion

        #region Get Pending Timesheets for Approval
        Task<List<GetApprovalTimesheetsDTO>> GetPendingApprovalTimesheets(int userId);

        #endregion

        #region Get Approved Timesheets

        Task<List<GetApprovedTimesheets>> GetApprovedTimesheetsAsync(int userID);

        #endregion

        #region Get Timesheet By TimesheetID
        Task<IEnumerable<GetTimesheetLineDTO>> GetTimesheetLinesByTimesheetIDAsync(int timesheetID);
        #endregion

        #region Get Timesheet Dropdown data
        Task<List<GetTimesheetHdrDTO>> GetTimesheetDropdown(int userId);
        #endregion

        #region Get Previous timesheets
        Task<List<GetPreviousTimesheets>> GetPreviousTimesheetsAsync(int userID);
        #endregion

        #region Reject Timesheet
        Task<int> RejectTimesheetAsync(PostRejectTimesheetDTO timesheetRejection);
        #endregion

        #region Get Timesheet Comments

        Task<List<GetTimesheetCommentsDTO>> GetTimesheetCommentsAsync(int timesheetId);

        #endregion

    }
}