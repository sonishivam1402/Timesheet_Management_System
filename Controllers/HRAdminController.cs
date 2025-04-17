using Microsoft.AspNetCore.Mvc;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Data.Repositories;
using UCITMS.Models;


namespace UCITMS.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HRAdminController : ControllerBase
    {
        private readonly IHRAdminRepository _hrAdminRepository;
        private readonly INotificationRepository _notificationRepository;
        private readonly IManagerDelegateRepository _managerDelegateRepository;
        private IAuthorizationRepository _authorizationRepository;

        #region Constructor
        public HRAdminController(IHRAdminRepository hrAdminRepository, INotificationRepository notificationRepository, IManagerDelegateRepository managerDelegateRepository, IAuthorizationRepository authorizationRepository)
        {
            _hrAdminRepository = hrAdminRepository;
            _notificationRepository = notificationRepository;
            _managerDelegateRepository = managerDelegateRepository;
            _authorizationRepository = authorizationRepository;
        }
        #endregion

        #region GET API for Primary Approver Dropdown
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Assign_Approver)]
        [HttpGet("getallmanagers")]
        public async Task<IActionResult> GetAllManagersInfo()
        {
            List<GetAllManagersDTO> managersInfo = await
                _managerDelegateRepository.GetAllManagersInfoAsync();
            return Ok(managersInfo);
        }
        #endregion

        #region GET API for Secondary Approver Dropdown
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Assign_Approver)]

        [HttpGet("GetAllUsers")]
        public async Task<ActionResult<List<UserDTO>>> GetAllUsers()
        {
            //int currentUserId = (int)UserSession.GetUserId(HttpContext);
            var users = await _hrAdminRepository.GetAllUsers();
            if (users == null || users.Count == 0)
            {
                return NotFound("No users found.");
            }
            return Ok(users);
        }
        #endregion

        #region Get API for AssignApprover

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Assign_Approver)]
        [HttpGet("getallusermanagerinfo")]
        public async Task<IActionResult> GetAllUserManagerInfo()
        {
            List<GetUserManagerDTO> userManagerInfo = await _hrAdminRepository.GetUserManagerInfoAsync();
            return Ok(userManagerInfo);
        }
        #endregion

        #region POST API for AssignApprover
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Assign_Approver)]
        [HttpPost("save")]
        public async Task<IActionResult> AddOrUpdateApprovers([FromBody] PostUserManagerDTO usermanager)
        {
            
            usermanager.ModUserID = UserSession.GetUserId(HttpContext);
            ValidateApproverDTO obj = await _hrAdminRepository.AddOrUpdateApproversAsync(usermanager);
            if (obj.Status == -1 || obj.Status == -2 || obj.Status == -3 || obj.Status == -4)
            {
                return BadRequest(obj);
            }
            else if(obj.Status == 1)
            {
                return Ok(obj);
            }
            else
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new { Status = 0, Message = "An unexpected error occurred." });
            }

        }
        #endregion

        #region GET API for Users With No Approver List
        [HttpGet("getnoapproverlist")]
        public async Task<IActionResult> GetNoApproverList()
        {
            var userNoApproverCount = await _hrAdminRepository.GetListNoApproverAsync();
            return Ok(userNoApproverCount);
        }
        #endregion

        #region Send Pending Approval Email
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Approval_Status)]
      
        [HttpPost("sendpendingEmail")]
        public IActionResult SendPendingEmail([FromBody] NotifyApproverPost obj)
        {
            int moduser = (int)UserSession.GetUserId(HttpContext);

            if (!_authorizationRepository.TimesheetAccess(AutherizationType.CanNotifyApprover, obj.TimesheetID, moduser))
            {
                return Unauthorized(new { error = "You are not authorized to notify this manager!!" });
            }

            bool isSent = _notificationRepository.SendNotifyApprover(obj.ManagerId, obj.UserID, obj.TimesheetID);
            if (isSent)
            {
                return Ok("Notification sent successfully.");
            }
            else {
                return BadRequest("Failed to send notification");
            }
        }


        #endregion

        #region Save Notified Logs
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Approval_Status)]
        [HttpPost("SaveNotifiedEmailLog")]
        public IActionResult SaveNotifiedEmailLog([FromBody] NotifiedEmailLog model)
        {
            if (model == null)
            {
                return BadRequest("Invalid data.");
            }

            var isSaved = _hrAdminRepository.SaveNotifiedEmailLog(model);

            if (isSaved)
            {
                return Ok(new { Message = "Data saved successfully." });
            }

            return StatusCode(500, "An error occurred while saving the data.");
        }
        #endregion

        #region Get Notified Logs

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Approval_Status)]
        [HttpGet("getnotifieddata")]
        public async Task<ActionResult> GetNotifiedData()
        {
            var timesheets = await _hrAdminRepository.GetNotifiedDataAsync();
            return Ok(timesheets);
        }
        #endregion

    }
}
