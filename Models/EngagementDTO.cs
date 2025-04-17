using System.ComponentModel.DataAnnotations;

namespace UCITMS.Models
{
    #region Get all engagements for employee and hr
    public class GetAllEngagementsDTO
    {
        public int EngagementID { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public string? Owners { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? TeamMembers { get; set; }
    }
    #endregion

    #region Get engagements for admin
    public class GetEngagementForAdminDTO
    {
        public int EngagementID { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int? EngagementScopeID { get; set; }
        public DateTime ModifiedOn { get; set; }
        public string? ModifiedBy { get; set; }
    }
    #endregion

    #region Post engagement for admin
    public class PostEngagementForAdminDTO
    {
        public int EngagementID { get; set; }
        public int EngagementScopeID { get; set; }
        public int ModifiedBy { get; set; }
    }
    #endregion

    #region Get engagement for manager
    public class GetEngagementDTO
    {
        public int EngagementID { get; set; }
        public string Title { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public List<TeamMemberDTO> TeamMembers { get; set; } = new List<TeamMemberDTO>();
        public List<GetTaskDTO> Tasks { get; set; } = new List<GetTaskDTO>();
        public List<OwnerDTO> Owners { get; set; } = new List<OwnerDTO>();
    }
    #endregion

    #region Post engagement for manager
    public class PostEngagementDTO
    {
        public int EngagementID { get; set; }
        public string Title { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string? Description { get; set; }
        public List<TeamMemberDTO> TeamMembers { get; set; } = new List<TeamMemberDTO>();
        public List<PostTaskDTO> Tasks { get; set; } = new List<PostTaskDTO>();
        public List<OwnerDTO> Owners { get; set; } = new List<OwnerDTO>();
        public int? ModUser { get; set; }

    }
    #endregion

    #region Engagement owner
    public class OwnerDTO
    {
        public int MappingID { get; set; }
        public int EngagementID { get; set; }
        public int UserID { get; set; }
        public string? OwnerName { get; set; }
    }
    #endregion

    #region Engagement task

    #region Get task
    public class GetTaskDTO
    {
        public int EngagementTaskID { get; set; }
        public int EngagementID { get; set; }
        public int TaskID { get; set; }
        public string? TaskName { get; set; }
        public string? TaskDescription { get; set; }
        public bool IsDeleted { get; set; }
        public bool IsGeneric { get; set; }
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public DateTime ModifiedOn { get; set; }
        public string ModifiedBy { get; set; }

    }
    #endregion

    #region Get Task with Moduser

    public class TaskResponseDTO
    {
        public string UserName { get; set; }
        public IEnumerable<GetTaskDTO> Tasks { get; set; }
    }

    #endregion

    #region Post task
    public class PostTaskDTO
    {
        public int EngagementTaskID { get; set; }
        public int EngagementID { get; set; }
        public int TaskID { get; set; }
        public string? TaskName { get; set; }
        public string? TaskDescription { get; set; }
        public bool IsDeleted { get; set; }
        public bool IsGeneric { get; set; }
        public int ModUser { get; set; }
    }
    #endregion

    #endregion

    #region Engagement Team Member
    public class TeamMemberDTO
    {
        public int MappingID { get; set; }
        public int UserID { get; set; }
        public string? TeamMemberName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int MaxWeeklyHours { get; set; }
        public int? CreatedBy { get; set; }
        public int? ModifiedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public DateTime? CreatedOn { get; set; }
        public int EngagementID { get; set; }
    }
    #endregion

    # region Delete engagement response
    public class DeleteEngagementResponse
    {
        public bool CanDelete { get; set; }
        public string? Message { get; set; }
    }

    #endregion

    #region Delete task response
    public class DeleteTaskResponse
    {
        public bool CanDelete { get; set; }
        public string? Message { get; set; }
    }

    #endregion
}