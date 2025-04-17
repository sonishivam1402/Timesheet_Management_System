namespace UCITMS.Models
{
    public class ReportsDTO
    {

        public string Employee { get; set; }
        public int ManagerId { get; set; }
        public int SecondaryManagerId { get; set; }

        public int UserId { get; set; }

        public string SecondaryManagerName { get; set; }
        public DateTime? SubmittedOn { get; set; }
        public DateTime? ApprovedOn { get; set; }

        public string ApprovedByName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        public string StatusName { get; set; }
        public string Duration { get; set; }

        public string EngagementName { get; set; }

        public string TaskName { get; set; }
        public DateTime? EntryDate { get; set; }

        public double TotalHours { get; set; }
        public string Comments { get; set; }
    }

    public class ReportsSchemaDTO
    {
        public int ID { get; set; }
        public string ViewName { get; set; }
        public string Slice {  get; set; }
        public string Formats { get; set; }
        public bool forSU { get; set; }
    }

}
