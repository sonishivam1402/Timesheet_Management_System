namespace UCITMS.Models
{
    #region Get Users Without Approvers LIST
    public class UsersListDTO
    {
        public int UserID { get; set; }
        public string UserName { get; set; }

    }
    #endregion

    #region Get user manager info
    public class GetUserManagerDTO
    {
        public int UserID { get; set; }
        public string? UserName { get; set; }
        public string? PrimaryManagerName { get; set; }
        public string? SecondaryManagerName { get; set; }
        public string? ModUserName { get; set; }
        public DateTime ModifiedOn { get; set; }

    }
    #endregion

    #region Post user manager info
    public class PostUserManagerDTO
    {
        public int UserID { get; set; }
        public int? PrimaryManagerID { get; set; }
        public int? SecondaryManagerID { get; set; }
        public int? ModUserID { get; set; }
    }
    #endregion

    #region Validate Approvers Data
    public class ValidateApproverDTO
    {
        public int Status { get; set; }
        public string Message { get; set; }
    }
    #endregion

    #region Get Users Without Approvers LIST
    public class UsersNoApproverListDTO
    {
        public int UserID { get; set; }
        public string UserName { get; set; }
        
    }
    #endregion

}