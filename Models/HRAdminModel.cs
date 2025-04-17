using System;

namespace UCITMS.Models
{
    public class NotifiedEmailLog     //post
    {
        public int LogId { get; set; }
        
        public int UserID { get; set; }
        public int ManagerID { get; set; }
        public int TimesheetID { get; set; }
        public DateTime SentOn { get; set; }
    }

    public class NotifiedEmailLogAsync    //get
    {
        public int TimesheetID { get; set; }
        public int UserID { get; set; }
        public string UserName { get; set; }
        public int Status { get; set; }
        public string tsDuration { get; set; }
        public string? SubmissionComment { get; set; }
        public int DaysDue { get; set; }
        public int ManagerId { get; set; }
        public string ManagerName { get; set; }
        public DateTime? LastNotifiedOn { get; set; }
    }

}
