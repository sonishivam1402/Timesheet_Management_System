using Microsoft.AspNetCore.Mvc;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Data.Repositories;
using UCITMS.Models;
    
namespace UCITMS.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DashboardController : Controller
    {
        #region Dependency Injection
        private readonly IDashboardRepository _dashboardRepository;
        private readonly IHRAdminRepository _hrAdminRepository;
        private readonly IManagerDelegateRepository _managerDelegateRepository;

        public DashboardController(IDashboardRepository dashboardRepository, IHRAdminRepository hRAdminRepository, IManagerDelegateRepository managerDelegateRepository)
        {
            _dashboardRepository = dashboardRepository;
            _hrAdminRepository = hRAdminRepository;
            _managerDelegateRepository = managerDelegateRepository;
        }
        #endregion

        #region GET API for Employee Dashboard

            #region GET API for Latest TS and Defaults
            [AppAuthorizationFilter(AutherizationType.Menu, Item.Employee_Dashboard)]
            [HttpGet("getlatesttsanddefaults")]
            public async Task<IActionResult> GetLastTimesheetAndDefaults()
            {
                int? id = (int)UserSession.GetUserId(HttpContext);
                var result = await _dashboardRepository.GetLastTSDateAndDefaultsAsync(id);
                return Ok(result);
            }
            #endregion

            #region Get API for Employee's Approvers
            [AppAuthorizationFilter(AutherizationType.Menu, Item.Employee_Dashboard)]
            [HttpGet("getuserapproverinfo")]
            public async Task<IActionResult> GetUserManagerInfo()
            {
                int? id = (int)UserSession.GetUserId(HttpContext);
                GetUserManagerDTO userApproverInfo = await _dashboardRepository.GetUserApproverInfoAsync(id);
                return Ok(userApproverInfo);
            }
        #endregion

            #region GET API for Employee Defaults
            [AppAuthorizationFilter(AutherizationType.Menu, Item.Employee_Dashboard)]
            [HttpGet("getemployeedefaults")]
            public async Task<IActionResult> GetEmpDefaults()
            {
                int? id = (int)UserSession.GetUserId(HttpContext);
                var result = await _dashboardRepository.GetEmployeeDefaults(id);
                return Ok(result);
            }
            #endregion

        #endregion

        #region GET API for Manager Dashboard

        #region Pending Approvals Count
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manager_Dashboard)]
        [HttpGet("getpendingapprovalscount")]
        public async Task<IActionResult> GetPendingApprovalsCount()
        {
            int? id = (int)UserSession.GetUserId(HttpContext);
            var result = await _dashboardRepository.GetPendingApprovalCountAsync(id);
            return Ok(result);
        }
        #endregion

            #region Managed Users
            [AppAuthorizationFilter(AutherizationType.Menu, Item.Manager_Dashboard)]
            [HttpGet("getmanagedusers")]
            public async Task<IActionResult> GetAllManagedUsers()
            {
                int? id = (int)UserSession.GetUserId(HttpContext);
                var result = await _dashboardRepository.GetAllManagedUsersAsync(id);
                return Ok(result);
            }
        #endregion

            #region Manager Defaulters

            [AppAuthorizationFilter(AutherizationType.Menu, Item.Manager_Dashboard)]
            [HttpGet("getmanagerdefaulters")]
            public async Task<IActionResult> GetManagerDefaulters()
            {
                int? id = (int)UserSession.GetUserId(HttpContext);
                var result = await _dashboardRepository.GetManagerDefaulterInfoAsync(id);
                return Ok(result);  
            }

            #endregion

            #region Delegate Name
        [HttpGet("getdelegatetimespan")]
            public async Task<IActionResult> GetDelegateTimeSpan()
            {
                int? id = (int)UserSession.GetUserId(HttpContext);
                var result = await _dashboardRepository.GetDelegateTimeSpanInfoAsync(id);
                return Ok(result);
            }

        #endregion

            #region Delegate Details

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manager_Dashboard)]
        [HttpGet("getdelegateinfo")]
        public async Task<IActionResult> GetDelegateInfo()
        {
            int? id = (int)UserSession.GetUserId(HttpContext);
            GetManagerDelegateDTO userApproverInfo = await _dashboardRepository.GetDelegateInfoAsync(id);
            return Ok(userApproverInfo);
        }

        #endregion

            #region POST API for AssignDelegate

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manager_Dashboard)]
        [HttpPost("save")]
        public async Task<IActionResult> AddOrUpdateDelegates([FromBody] PostManagerDelegateDTO managerdelegate)
        {
            managerdelegate.ModUser = UserSession.GetUserId(HttpContext);
            managerdelegate.ManagerID = managerdelegate.ModUser;
            string msg = await _managerDelegateRepository.AddOrUpdateDelegatesAsync(managerdelegate);
            return Ok(msg);

        }

        #endregion

        #endregion

        #region GET API for HR Dashboard

        #region Defaulters Count
        [AppAuthorizationFilter(AutherizationType.Menu, Item.HR_Admin_Dashboard)]
            [HttpGet("getdefaulterscount")]
            public async Task<IActionResult> GetDefaultersCount()
            {
                int? id = (int)UserSession.GetUserId(HttpContext);
                var result = await _dashboardRepository.GetTotalDefaultersAsync();
                return Ok(result);
            }
            #endregion

            #region Missing Approver Count
            [AppAuthorizationFilter(AutherizationType.Menu, Item.HR_Admin_Dashboard)]
            [HttpGet("getmissingapprovercount")]
            public async Task<IActionResult> GetNoApproverCount()
            {
                var userNoApproverCount = await _dashboardRepository.GetCountNoApproverAsync();
                return Ok(userNoApproverCount);
            }
        #endregion

        #endregion

        #region Get All users

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manager_Dashboard)]

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


    }
}

