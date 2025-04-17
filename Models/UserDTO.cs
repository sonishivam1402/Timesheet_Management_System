namespace UCITMS.Models
{
    #region User DTO for login purpose
    public class UserDTO
    {
        public int UserID { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }

        public string EnvVar { get; set; }
    }
    #endregion
}
