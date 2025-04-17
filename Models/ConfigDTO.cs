namespace UCITMS.Models
{
    #region Get Configurations for admin
    public class GetConfigDTO
    {
        public int Id { get; set; } 
        public string Name { get; set; } 
        public string Description { get; set; }
        public string Value { get; set; }
        public int ModifiedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public string ModifiedByName { get; set; }
    }
    #endregion

    #region Post Configuration for admin
    public class PostConfigDTO
    {
        public int Id { get; set; }
        public string Value { get; set; }
        public int ModifiedBy { get; set; }
    }
    #endregion
}
