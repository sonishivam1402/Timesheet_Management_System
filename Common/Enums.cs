namespace UCITMS.Common
{
    public enum AutherizationType
    {
        Menu=1,
        Action=2,
        ReadTimesheet = 3,
        EditTimesheet = 4,
        ReviewTimesheet = 5,
        SubmitTimesheet = 6,
        AddEditTimesheetLine = 7,
        DeleteTimesheetLine = 8,
        SaveEngagement = 9,
        ViewEngagement = 10,
        InactivateNotification = 11,
        AddTimesheetTask = 12,
        EditTimesheetLineId = 13,
        CanNotifyApprover = 14
    }
    public enum Item
    {

        HR_Admin_Dashboard = 12,
        Approval_Status = 13,
        Assign_Approver=14,
        Active_Engagements = 15,
        Assign_Delegate = 25,

        Manager_Dashboard = 16,
        Pending_Approval = 17,
        Approved_Timesheets = 18,
        Manage_My_Engagements =19,

        Employee_Dashboard = 20,
        Add_new_Timesheet =21,
        View_Previous_Timesheets = 22,
        My_Engagements =23,

        Config_Settings = 26,
        Admin_Dashboard = 30,
        System_User = 33,
        Manage_Engagements = 34,

        Reports = 35,
        Organizational_Structure = 36
    }
    public enum ConfigType
    {
        DEFAULT_TIMESHEET_START_DATE = 1,
        WORK_HOUR_PER_DAY = 3,
        APPROVAL_EMAIL_SUBJECT=4,
        CURRENT_SITE_BASE_URL=5,
        SENDER_NAME=6,
        TIMESHEET_REJECT_EMAIL_SUBJECT = 7,
        SYSTEM_BCC_EMAILS = 8,
        SMTP_SERVER = 9,
        SMTP_PORT = 10,
        SMTP_USER = 11,
        SMTP_USER_PWD_ENCRYPTED = 12,
        EnableSsl = 13,
        ForceRedirect = 14,
        NOTIFY_APPROVER_EMAIL_SUBJECT = 15
    }
    public enum TemplateType
    {
        Approvar_Email_Main_Body_Container = 1,
        Approvar_Email_Table_Template = 2,
        Approvar_Email_Table_Row_Template = 3,
        Employee_Email_On_Timesheet_Rejection = 4,
        Notify_Approver_Template = 5

    }

    public enum NotificationType
    {
        TimesheetApproved = 1,
        TimesheetRejected = 2,
        ApproverChanged = 3,
        RoleChanged = 4,
        NewEngagement = 5,
    }
    public enum GenericCommandType
    {
        TimesheetCountByStatus = 1,
        TimesheetSummaryReport = 2
    }
}
