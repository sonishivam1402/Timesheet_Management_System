using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface INotificationRepository
    {
        #region Helper Methos To Send Mail
        void SendMail(NotificationDTO objEmail);
        #endregion

        #region Send Approval Emails
        Task SendApprovalEmails();
        #endregion

        #region Send Timesheet Reject Emails
        void SendTimesheetRejectEmail(int TimesheetId);
        #endregion

        #region Capture Notification
        void CaptureNotification(CaptureNotificationDTO objNotification);
        #endregion

        #region Send Pending Approval Emails
        //void SendNotifyApprover(int ManagerId, int UserId, int TimesheetId);
        bool SendNotifyApprover(int ManagerId, int UserId, int TimesheetId);

        #endregion

        #region Bell icon notification
        int GetNotificationCount(int userId);

        Task<List<GetNotificationDTO>> GetNotificationsAsync(int userId);
        Task<bool> MarkNotificationAsInactiveAsync(int recordId, int modUser);
        Task<bool> MarkNotificationsAsReadAsync(int userId);
        #endregion
    }
}
