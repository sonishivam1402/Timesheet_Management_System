namespace UCITMS.Models
{
    public class AuditTrailDTO
    {
        public int LogId { get; set; }
        public int TableId { get; set; }
        public string TableName { get; set; }
        public int TableKey { get; set; }
        public string FieldName { get; set; }
        public string PreviousValue { get; set; }
        public string NewValue { get; set; }
        public int ModifiedBy { get; set; }
        public DateTime ModifiedOn { get; set; }
        public string BatchId { get; set; }
    }
}
