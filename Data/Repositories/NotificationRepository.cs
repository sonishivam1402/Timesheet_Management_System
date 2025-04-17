using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;
using System.Net.Mail;
using System.Net;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using UCITMS.ViewModels;
using UCITMS.Common;

namespace UCITMS.Data.Repositories
{
    public class NotificationRepository : INotificationRepository
    {
        #region Variables and Constructors

        private string _connectionString;
        private IConfiguration _configuration;
        private IAppConfigRepository _AppConfig;

        public NotificationRepository(IConfiguration configuration, IAppConfigRepository _appConfig)
        {
            _configuration = configuration;
            _AppConfig = _appConfig;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }
        #endregion

       #region Send Approval Emails
        public Task SendApprovalEmails() {

            List<ApprovalEmailItem> approvers = GetApprvers();
            foreach (ApprovalEmailItem _approver in approvers)
            {
                NotificationDTO _objMail= GetNotificationData(_approver);
                if (_objMail != null) { 
                    SendMail(_objMail);
                    foreach (TimeSheetItems _item in _approver.TimesheetItems)
                    {
                        UpdateSentStatus(_item);
                    }
                }
            }
            return Task.CompletedTask;
        }
        #endregion

        #region Mark Notification as Sent
        public void UpdateSentStatus(TimeSheetItems _item)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.UpdateNotificationSentStatus", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@WorkFlowId", _item.WorkflowId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

        }
        #endregion

        #region Create Email Object for Each Manager
        private NotificationDTO GetNotificationData(ApprovalEmailItem item)
        {
            NotificationDTO objEmail=new NotificationDTO();
            objEmail.EmailCategory = "Manager Email for Approval";
            objEmail.to = item.Primaryapprover.Email;
            objEmail.subject = _AppConfig.GetValue(Common.ConfigType.APPROVAL_EMAIL_SUBJECT);
            objEmail.body = CreateEmailBody(item);
            return objEmail;

        }
        #endregion

        #region Get List of All Managers
        public List<ApprovalEmailItem> GetApprvers()
        {
            List<ApprovalEmailItem> items = new List<ApprovalEmailItem>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetapproverForNotification", conn);
                cmd.CommandType = CommandType.StoredProcedure;
              
              conn.Open();

                using (SqlDataReader reader =cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ApprovalEmailItem _item = new ApprovalEmailItem();
                        _item.Primaryapprover = new approver();
                        _item.Primaryapprover.UserId = reader.GetInt32(reader.GetOrdinal("ManagerID"));
                        _item.Primaryapprover.Name = reader.GetString(reader.GetOrdinal("ManagerName"));
                        _item.Primaryapprover.Email = reader.GetString(reader.GetOrdinal("ManagerEmail"));
                        GetTimesheetForApproval(_item);
                        items.Add(_item);
                    }
                }
            }

            return items;

        }
        #endregion

        #region All Pending Timesheets under the manager
        public void GetTimesheetForApproval(ApprovalEmailItem _item)
        {
            _item.TimesheetItems = new List<TimeSheetItems>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetTimesheetsForEmailNotifications", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ManagerID", _item.Primaryapprover.UserId);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        TimeSheetItems _TimeSheetItem = new TimeSheetItems();
                        _TimeSheetItem.TimesheetID = reader.GetInt32(reader.GetOrdinal("TimesheetID"));
                        _TimeSheetItem.WorkflowId = reader.GetInt32(reader.GetOrdinal("WorkflowId"));                        
                        _TimeSheetItem.EmployeeName = reader.GetString(reader.GetOrdinal("EmployeeName"));
                        _TimeSheetItem.DisplayTitle = reader.GetString(reader.GetOrdinal("DisplayTitle"));
                        _TimeSheetItem.Hours = reader.GetInt32(reader.GetOrdinal("HoursTotal"));
                        _TimeSheetItem.SubmissionComment = reader.IsDBNull("SubmissionComment") ? null : reader.GetString("SubmissionComment");
                        _TimeSheetItem.SubmittedOn = reader.GetDateTime(reader.GetOrdinal("SubmittedOn"));
                        _item.TimesheetItems.Add(_TimeSheetItem);
                    }
                }
            }

        } 
        #endregion

        #region Main Method to Create Email Body 
        private string CreateEmailBody(ApprovalEmailItem objItem)
        {
            string EmailBody = _AppConfig.GetTemplate(Common.TemplateType.Approvar_Email_Main_Body_Container);

            EmailBody = EmailBody.Replace("{{UserName}}",objItem.Primaryapprover.Name);
            EmailBody = EmailBody.Replace("{{LinkURL}}", _AppConfig.GetValue(Common.ConfigType.CURRENT_SITE_BASE_URL) + "?redirect=PendingApprovals");

            
            #region genrate Email Table
            string tblData = _AppConfig.GetTemplate(Common.TemplateType.Approvar_Email_Table_Template);
            string trData = "";
        
            #region Now Add Single Row for table
            int RowCounter= 0; ;
            foreach (TimeSheetItems _i in objItem.TimesheetItems)
            {
                RowCounter++;
                string _row = _AppConfig.GetTemplate(Common.TemplateType.Approvar_Email_Table_Row_Template); 
                _row = _row.Replace("{{SNo}}", RowCounter.ToString());
                _row = _row.Replace("{{EmpName}}", _i.EmployeeName);
                _row = _row.Replace("{{DisplayTitle}}", _i.DisplayTitle.ToString());
                _row = _row.Replace("{{SubmittedOn}}", _i.SubmittedOn.ToString());
                _row = _row.Replace("{{SubmissionComment}}", _i.SubmissionComment);
                trData = trData + _row;


            }

            #endregion

            tblData = tblData.Replace("{{TableRows}}", trData);
            #endregion

            EmailBody = EmailBody.Replace("{{TableData}}", tblData);

            return EmailBody;

        }

        #endregion

        #region Send Email Methods on Timesheet Rejection

        #region Main Method To Send Reject Email 
        public void SendTimesheetRejectEmail(int TimesheetId)
        {
            NotificationDTO _objMail = new NotificationDTO();
            RejectEmail objData= CreateRejectEmailObject(TimesheetId);
            _objMail.EmailCategory = "Timesheet Rejection Email";
            _objMail.to = objData.EmployeeEmail;
            _objMail.subject = _AppConfig.GetValue(Common.ConfigType.TIMESHEET_REJECT_EMAIL_SUBJECT);
            _objMail.subject = _objMail.subject.Replace("{{TimesheetDuration}}", objData.TimesheetDuration);
            _objMail.body = CreateRejectEmailBody(objData);
            SendMail(_objMail);



        }
        #endregion

        #region Create Email body using Template from Database
        private string CreateRejectEmailBody(RejectEmail objEmail)
        {
            string EmailBody = _AppConfig.GetTemplate(Common.TemplateType.Employee_Email_On_Timesheet_Rejection);
            EmailBody = EmailBody.Replace("{{UserName}}", objEmail.EmployeeName);
            EmailBody = EmailBody.Replace("{{TSDuration}}", objEmail.TimesheetDuration);
            EmailBody = EmailBody.Replace("{{ManagerName}}", objEmail.ManagerName);
            EmailBody = EmailBody.Replace("{{RejectionComments}}", objEmail.RejectionComment);
            return EmailBody;
        }
        #endregion

        #region Create Reject Email Object using Stored Proc
        private RejectEmail CreateRejectEmailObject(int TimesheetId) {

            RejectEmail objEmail=new RejectEmail();
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetRejectEmailContent", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TimesheetId", TimesheetId);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        objEmail.RejectionComment = reader.IsDBNull(reader.GetOrdinal("RejectionComment"))? null : reader.GetString(reader.GetOrdinal("RejectionComment")); 
                        objEmail.EmployeeName = reader.GetString(reader.GetOrdinal("EmployeeName"));
                        objEmail.EmployeeEmail = reader.GetString(reader.GetOrdinal("EmployeeEmail"));
                        objEmail.ManagerName = reader.GetString(reader.GetOrdinal("ManagerName"));
                        objEmail.TimesheetDuration = reader.GetString(reader.GetOrdinal("TimesheetDuration"));

                    }
                }
            }



            return objEmail;
        }
        #endregion

        #endregion


        #region Global Send Email Helper Method
        public void SendMail(NotificationDTO objEmail)
        {

            #region Load SMTP Config Value from DataBase
            string SMTPServer = _AppConfig.GetValue(ConfigType.SMTP_SERVER);
            int SMTPPort =int.Parse(_AppConfig.GetValue(ConfigType.SMTP_PORT));
            string SystemEmail = _AppConfig.GetValue(ConfigType.SMTP_USER);
            string SystemPassword = _AppConfig.GetValue(ConfigType.SMTP_USER_PWD_ENCRYPTED);
            bool EnableSsl =bool.Parse(_AppConfig.GetValue(ConfigType.EnableSsl));
            bool ForceRedirect = bool.Parse(_AppConfig.GetValue(ConfigType.ForceRedirect));
            //reversing the string (VERY WEAK CONFIG)
            SystemPassword = new string(SystemPassword.ToCharArray().Reverse().ToArray());
            #endregion
            #region Set Up SMTP Client
            var smtpClient = new SmtpClient(SMTPServer)
            {
                Port = SMTPPort,
                Credentials = new NetworkCredential(SystemEmail, SystemPassword),
                EnableSsl = EnableSsl,
            };
            #endregion

            #region Create Message Object
            MailMessage message = new MailMessage();
            //message.From = new MailAddress(objEmail.from);
            message.Subject = objEmail.subject;
            
            message.Body = objEmail.body;
            message.Priority = MailPriority.Normal;
            message.IsBodyHtml = true;
            MailAddress from = new MailAddress(SystemEmail, _AppConfig.GetValue(Common.ConfigType.SENDER_NAME));
            message.From = from;
            #endregion

            #region Add To
            //to fields can be sepearted by comma or semicolon
            objEmail.to = objEmail.to.Replace(",", ";");
            foreach (string email in objEmail.to.Split(';'))
            {
                message.To.Add(email);
            }
            #endregion

            #region Add CC
            //fields can be sepearted by comma or semicolon
            if (!string.IsNullOrEmpty(objEmail.cc))
            {
                objEmail.cc = objEmail.cc.Replace(",", ";");
                foreach (string email in objEmail.cc.Split(';'))
                {
                    message.CC.Add(email);
                }
            }
            #endregion

            #region Add BCC 
            objEmail.bcc = _AppConfig.GetValue(ConfigType.SYSTEM_BCC_EMAILS);
            if (!string.IsNullOrEmpty(objEmail.bcc))
            {
                objEmail.bcc = objEmail.bcc.Replace(",", ";");
                foreach (string email in objEmail.bcc.Split(';'))
                {
                    message.Bcc.Add(email);
                }
            }
            #endregion


            #region If Force Redirect is Enabled 
            if (ForceRedirect)
            {
                message.Subject = $"** FORCED REDIRECTED EMAIL *** {message.Subject}";
                message.Body = $"<FONT COLOR=RED><U>THIS IS FORCED REDIRECTED EMAIL, DISABLE THIS SETTING FROM CONFIGURATION AFTER TESTING IS COMPLETE</U></FONT><HR>{message.Body}";
                message.To.Clear();

                //Here we are adding BCC list into To Field
                if (!string.IsNullOrEmpty(objEmail.bcc))
                {
                    objEmail.bcc = objEmail.bcc.Replace(",", ";");
                    foreach (string email in objEmail.bcc.Split(';'))
                    {
                        message.To.Add(email);
                    }
                }
                else {
                    message.To.Add("ritesh@uciny.com");
                }


                message.Bcc.Clear();


            }

            #endregion



            smtpClient.Send(message);
            
            SaveEmailLog(objEmail, from.Address);
        }
        #region Save Email Log
        public void SaveEmailLog(NotificationDTO objEmail,string EmailFrom)
        {

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.SaveEmailLogs", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Category", objEmail.EmailCategory);
                cmd.Parameters.AddWithValue("@SentTo", objEmail.to);
                cmd.Parameters.AddWithValue("@SentFrom", EmailFrom);
                cmd.Parameters.AddWithValue("@Subject", objEmail.subject);
                cmd.Parameters.AddWithValue("@EmailBody", objEmail.body);
                cmd.Parameters.AddWithValue("@CC", objEmail.cc != null ? objEmail.cc : "" );
                cmd.Parameters.AddWithValue("@BCC", objEmail.bcc != null ? objEmail.bcc : "");
                conn.Open();
                cmd.ExecuteNonQuery(); 
            }

        }
        #endregion

        #endregion

        #region Bell Icon notification Region
        #region Capture Notification
        public void CaptureNotification(CaptureNotificationDTO objNotification)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("CaptureNotification", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", objNotification.UserId);
                    cmd.Parameters.AddWithValue("@NotificationId", (int)objNotification.NotificationType);
                    cmd.Parameters.AddWithValue("@ModUser", objNotification.ModUser);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        #endregion

        #region Get Notification count
        public int GetNotificationCount(int userId)
        {
            int notificationCount = 0;

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("dbo.GetNotificationCount", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    notificationCount = (int)cmd.ExecuteScalar();
                }
            }

            return notificationCount;
        }
        #endregion

        #region Get Notifications for User
        public async Task<List<GetNotificationDTO>> GetNotificationsAsync(int userId)
        {
            var notifications = new List<GetNotificationDTO>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                using (SqlCommand cmd = new SqlCommand("dbo.GetUserNotifications", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            notifications.Add(new GetNotificationDTO
                            {
                                RecordId = reader.GetInt32(reader.GetOrdinal("RecordId")),
                                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                                NotificationId = reader.GetInt32(reader.GetOrdinal("NotificationId")),
                                Title = reader.GetString(reader.GetOrdinal("Title")),
                                Description = reader.GetString(reader.GetOrdinal("Description")),
                                Icon = reader.GetString(reader.GetOrdinal("Icon")),
                                IsRead = reader.GetBoolean(reader.GetOrdinal("IsRead")),
                                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                                CreatedOn = reader.GetDateTime(reader.GetOrdinal("CreatedOn"))
                            });
                        }
                    }
                }
            }

            return notifications;
        }

        #endregion

        #region Mark notification as inactive
        public async Task<bool> MarkNotificationAsInactiveAsync(int recordId, int modUser)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                using (SqlCommand cmd = new SqlCommand("MarkNotificationInactive", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RecordId", recordId);
                    cmd.Parameters.AddWithValue("@ModUser", modUser);

                    var rowsAffected = await cmd.ExecuteScalarAsync();

                    return (int)rowsAffected > 0;
                }
            }
        }
        #endregion

        #region Mark notification as Read
        public async Task<bool> MarkNotificationsAsReadAsync(int userId)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                using (SqlCommand cmd = new SqlCommand("MarkNotificationsAsRead", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    var rowsAffected = await cmd.ExecuteScalarAsync();

                    return (int)rowsAffected > 0;
                }
            }
        }
        #endregion
        #endregion

        public bool SendNotifyApprover(int ManagerId, int UserId, int TimesheetId)
        {
            NotificationDTO _objMail = new NotificationDTO();

            NotifyApprover objData = CreateNotifyApproverObject(ManagerId, UserId, TimesheetId);
            _objMail.EmailCategory = "Reminder: Approve Pending Timesheets";
            _objMail.to = objData.Email;
            _objMail.subject = _AppConfig.GetValue(Common.ConfigType.NOTIFY_APPROVER_EMAIL_SUBJECT);
            _objMail.subject = _objMail.subject.Replace("{{tsDuration}}", objData.tsDuration);
            _objMail.subject = _objMail.subject.Replace("{{UserName}}", objData.UserName);
            _objMail.body = CreateNotifyApproverBody(objData);

            if (string.IsNullOrEmpty(_objMail.to) || string.IsNullOrEmpty(_objMail.body))
            {
                // return false if email or body is invalid
                return false;
            }

            SendMail(_objMail);
            return true;

        }

        private string CreateNotifyApproverBody(NotifyApprover objEmail)
        {
            string EmailBody = _AppConfig.GetTemplate(Common.TemplateType.Notify_Approver_Template);

            EmailBody = EmailBody.Replace("{{ManagerName}}", objEmail.ManagerName);
            EmailBody = EmailBody.Replace("{{UserName}}", objEmail.UserName);
            EmailBody = EmailBody.Replace("{{DaysDue}}", objEmail.DaysDue.ToString());
            EmailBody = EmailBody.Replace("{{UserID}}", objEmail.UserID.ToString());
            EmailBody = EmailBody.Replace("{{TimesheetID}}", objEmail.TimesheetID.ToString());
            EmailBody = EmailBody.Replace("{{tsDuration}}", objEmail.tsDuration);
            EmailBody = EmailBody.Replace("{{SubmissionDate}}", objEmail.SubmittedOn.ToString());
            EmailBody = EmailBody.Replace("{{SubmissionComments}}", objEmail.SubmissionComment.ToString());
            EmailBody = EmailBody.Replace("{{URL}}", _AppConfig.GetValue(Common.ConfigType.CURRENT_SITE_BASE_URL) + "?redirect=ApprovalStatus");

            Console.WriteLine(EmailBody.ToString());
            return EmailBody;
        }

        private NotifyApprover CreateNotifyApproverObject(int ManagerId,int UserId, int TimesheetId)
        {  

            NotifyApprover objEmail = new NotifyApprover();
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetNotifyApproverMail", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ManagerId", ManagerId);
                cmd.Parameters.AddWithValue("@UserID", UserId);
                cmd.Parameters.AddWithValue("@TimesheetID", TimesheetId);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        objEmail.UserID = reader.GetInt32(reader.GetOrdinal("UserID"));
                        objEmail.ManagerId = reader.GetInt32(reader.GetOrdinal("ManagerId"));
                        objEmail.UserName = reader.GetString(reader.GetOrdinal("UserName"));
                        objEmail.TimesheetID = reader.GetInt32(reader.GetOrdinal("TimesheetID"));
                        objEmail.Email = reader.GetString(reader.GetOrdinal("ManagerEmail"));
                        objEmail.ManagerName = reader.GetString(reader.GetOrdinal("ManagerName"));
                        objEmail.SubmittedOn = reader.GetDateTime(reader.GetOrdinal("SubmittedOn"));
                        objEmail.SubmissionComment = reader.IsDBNull(reader.GetOrdinal("SubmissionComment")) ? " " : reader.GetString(reader.GetOrdinal("SubmissionComment"));
                        objEmail.tsDuration = reader.GetString(reader.GetOrdinal("tsDuration"));
                        objEmail.DaysDue = reader.GetInt32(reader.GetOrdinal("DaysDue"));
                    }
                }
            }

            return objEmail;
        }
    }
}