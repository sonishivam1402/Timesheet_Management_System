namespace UCITMS.Models
{
    #region Get timesheet header
    public class GetTimesheetHdrDTO
    {
        public int TimesheetID { get; set; }
        public int UserID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int Status { get; set; }
        public int HoursTotal { get; set; }
        public int MinutesTotal { get; set; }
        public List<GetTimesheetLineDTO>? TimesheetLines { get; set; }
        public string DisplayTitle { get; set; }
    }
    #endregion

    #region Post timesheet header
    public class PostTimesheetHdrDTO
    {
        public int TimesheetID { get; set; }
        public int UserID { get; set; }
        public int HoursTotal { get; set; }
        public int MinutesTotal { get; set; }
        public string? SubmissionComment {  get; set; }
    }
    #endregion

    #region Get timehseet lines
    public class GetTimesheetLineDTO
    {
        public int LineID { get; set; }
        public int TimesheetID { get; set; }
        public int EngagementID { get; set; }

        public string EngagementName {  get; set; }
        public int TaskID { get; set; }
        public string TaskName { get; set; }
        public int Hours { get; set; }
        public int Minutes { get; set; }
        public DateTime Date { get; set; }
        public string? Comment { get; set; }
    }
    #endregion

    #region Post timesheet lines
    public class PostTimesheetLineDTO
    {
        public int? LineID { get; set; }
        public int TimesheetID { get; set; }
        public int EngagementID { get; set; }
        public int TaskID { get; set; }
        public int Hours { get; set; }
        public int Minutes { get; set; }
        public DateTime Date { get; set; }
        public string? Comment { get; set; }
        public int TotalDayHours { get; set; }
        public int TotalDayMinutes { get; set; }
        public int? ModUser { get; set; }
    }
    #endregion

    #region Get Pending Timesheets for Approval

    public class GetApprovalTimesheetsDTO

    {

        public int TimesheetID { get; set; }

        public string EmployeeName { get; set; }

        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        public int Hours { get; set; }

        public int Minutes { get; set; }

        public DateTime SubmittedOn { get; set; }

        public string? SubmissionComment { get; set; }

        public string DisplayTitle { get; set; }
        public int? CommentsCount {  get; set; }

    }

    #endregion

    #region Post Approve Timesheet

    public class PostApproveTimesheetDTO

    {
        public int TimesheetID { get; set; }
        public string? ApprovalComment { get; set; }
        public int ModUser {  get; set; }
    }

    #endregion

    #region Get Approved Timesheets
    public class GetApprovedTimesheets
    {
        public int TimesheetID { get; set; }
        public string EmployeeName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int HoursTotal { get; set; }

        public int MinutesTotal { get; set; }
        public DateTime? SubmittedOn { get; set; }
        public string SubmissionComment { get; set; }
        public DateTime? ApprovedOn { get; set; }
        public string ApprovalComment { get; set; }
        public string ApprovedBy { get; set; }
        public string DisplayTitle { get; set; }
        public int? CommentsCount { get; set; }
    }
    #endregion

    #region Get Previous Timesheets
    public class GetPreviousTimesheets
    {
        public int TimesheetID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int Status { get; set; }
        public int HoursTotal { get; set; }

        public int MinutesTotal { get; set; }
        public DateTime? SubmittedOn { get; set; }
        public string? SubmissionComment { get; set; }
        public DateTime? ApprovedOn { get; set; }
        public string? ApprovalComment { get; set; }
        public string? ApprovedBy { get; set; }
        public string DisplayTitle { get; set; }
        public int? CommentsCount { get; set; }
    }
    #endregion

    #region Post Reject Timesheet

    public class PostRejectTimesheetDTO

    {
        public int TimesheetID { get; set; }
        public string? RejectionComment { get; set; }
        public int ModUser { get; set; }
    }

    #endregion

    #region Get Timesheet Comments

    public class GetTimesheetCommentsDTO
    {
        public int TimesheetId { get; set; }
        public int CommentType { get; set; }
        public string CommentTypeText { get; set; }
        public string? CommentText { get; set; }
        public DateTime CommentDate { get; set; }
        public int CommentBy {  get; set; }
        public string CommentByUser { get; set; }
    }
    #endregion
}