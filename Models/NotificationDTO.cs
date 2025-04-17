using System.ComponentModel.DataAnnotations;
using UCITMS.Common;

namespace UCITMS.Models
{
    #region Notification Object
    public class NotificationDTO
    {
        
        //public string? from { get; set; }
        public string to { get; set; }
        public string subject { get; set; }
        public string body { get; set; }
        public string cc { get; set; }
        public string bcc { get; set; }
        public string EmailCategory { get; set; }
    }
    #endregion


    #region approver Mail

    public class ApprovalEmailItem
    {
        public approver Primaryapprover { get; set; }
        public List<approver>? Secondaryapprover { get; set; }
        public List<TimeSheetItems>? TimesheetItems { get; set; }


    }
    public class approver
    {
        public int UserId { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
 
    }
    public class TimeSheetItems
    {
        public int WorkflowId { get; set; }

        public int TimesheetID { get; set; }

        public string EmployeeName { get; set; }

        public DateOnly StartDate { get; set; }

        public DateOnly EndDate { get; set; }

        public int Hours { get; set; }

        public DateTime SubmittedOn { get; set; }

        public string? SubmissionComment { get; set; }
        public string DisplayTitle { get; set; }
    }

    public class RejectEmail
    {
        public string EmployeeName { get; set; }
        public string ManagerName { get; set; }

        public string EmployeeEmail { get; set; }
        public string TimesheetDuration { get; set; }

        public string? RejectionComment { get; set; }


    }
    #endregion

    #region Capture Notification
    public class CaptureNotificationDTO
    {
        public int UserId { get; set; }
        public NotificationType NotificationType { get; set; }
        public int ModUser { get; set; }
    }
    #endregion

    #region Notify Approver Model
    public class NotifyApprover
    {
         public int TimesheetID { get; set; }
        public int UserID { get; set; }
        public string UserName { get; set; }
        public string tsDuration { get; set; }
        public DateTime SubmittedOn { get; set; }

        public string? SubmissionComment { get; set; }
        public int DaysDue { get; set; }
        public int ManagerId { get; set; }
        public string ManagerName { get; set; }
        public string Email { get; set; }
        
    }
    #endregion

    public class NotifyApproverPost
    {
        public int TimesheetID { get; set; }
        public int UserID { get; set; }
        public int ManagerId { get; set; }
    }

        #region Get user notification
        public class GetNotificationDTO
    {
        public int RecordId { get; set; }
        public int UserId { get; set; }
        public int NotificationId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Icon { get; set; }
        public bool IsRead { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedOn { get; set; }
    }


    #endregion

}