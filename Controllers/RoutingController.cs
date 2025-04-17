using Microsoft.AspNetCore.Mvc;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Controllers
{
    public class RoutingController : Controller
    {
        private readonly IUserInfoRepository _userinfoRepository;
        private readonly IMenuRepository _menuRepository;

        public RoutingController(IUserInfoRepository userInfoRepository, IMenuRepository menuRepository)
        {
            _userinfoRepository = userInfoRepository;
            _menuRepository = menuRepository;
        }

        //------------------------------
        //-X-X-X-X-X-X-X-X

        //FOR LOGIN

        //-X-X-X-X-X-X-X-X

        #region Login

        public IActionResult Login()
        {
            return View("Login/Index");
        }

        #endregion

        #region Landing Page
        public IActionResult LandingPage()
        {
            var user = _userinfoRepository.GetuserbyEmail(User.Identity.Name);
            if (user == null)
            {
                ViewBag.Message = "Invalid Credentials";
                return View("Login/Index");
            }

            if (user.IsActive == false)
            {
                return View("PageNotFound");
            }

            UserSession.StoreUserId(HttpContext, user.UserID);
            UserSession.StoreUserName(HttpContext, user.Username);
            UserSession.StoreUserEmail(HttpContext, user.Email);
            UserSession.StoreEnvVar(HttpContext, user.EnvVar);

            return RedirectToAction("HomePage");
        }
        #endregion

        #region Authentication 

        [HttpPost]
        public IActionResult Authenticate(string email = "")
        {


            if (string.IsNullOrEmpty(email))
            {
                email = User.Identity.Name;
            }

            UserDTO user = _userinfoRepository.GetuserbyEmail(email);
            if (user == null)
            {
                ViewBag.Message = "Invalid Credentials";
                return View("Login/Index");
            }

            if(user.IsActive == false)
            {
                return View("PageNotFound");
            }
            else
            {
                UserSession.StoreUserId(HttpContext, user.UserID);
                UserSession.StoreUserName(HttpContext, user.Username);
                UserSession.StoreUserEmail(HttpContext, user.Email);
                UserSession.StoreEnvVar(HttpContext, user.EnvVar);

                return RedirectToAction("HomePage");
            }
        }

        #endregion

        #region Home Page

        public async Task<IActionResult> HomePage()
        {
            int userId = (int)UserSession.GetUserId(HttpContext);

            int defaultMenuId = await _menuRepository.GetDefaultMenuIdByUserId(userId);

            if (defaultMenuId == 12)
                return RedirectToAction("HRDashboard");
            else if (defaultMenuId == 16)
                return RedirectToAction("Dashboard");
            else if (defaultMenuId == 20)
                return RedirectToAction("MyDashboard");

            return View("Home/Index");
        }
        #endregion

        //------------------------------
        //-X-X-X-X-X-X-X-X

        // ADMIN

        //-X-X-X-X-X-X-X-X

        #region Admin Dashboard

        [HttpGet("/AdminDashboard")]
        public IActionResult AdminDashboard()
        {
            return View("Admin/AdminDashboard");
        }

        #endregion

        #region System User

        [HttpGet("/SystemUsers")]
        public IActionResult SystemUsers()
        {
            return View("Admin/SystemUsers");
        }

        #endregion

        #region Config Settings Page
        [HttpGet("/ConfigSettings")]
        public IActionResult ConfigSettings()
        {
            return View("Admin/ConfigSettings");
        }
        #endregion

        #region Default Engagements Page
        [HttpGet("/ManageEngagements")]
        public IActionResult DefaultEngagements()
        {
            return View("Admin/ManageEngagements");
        }
        #endregion


        //------------------------------
        //-X-X-X-X-X-X-X-X

        // MANAGER

        //-X-X-X-X-X-X-X-X

        #region Manage Engagement

        [HttpGet("/ManageEngagement")]
        public IActionResult ManageEngagement()
        {
            return View("Manager/ManageEngagement");
        }
        #endregion

        #region Manager Dashboard

        [HttpGet("/ManagerDashboard")]
        public IActionResult Dashboard()
        {
            return View("Manager/ManagerDashboard");
        }
        #endregion

        #region Approved Timesheets

        [HttpGet("/ApprovedTimesheets")]
        public IActionResult ApprovedTimesheets()
        {
            return View("Manager/ApprovedTimesheets");
        }
        #endregion

        #region Pending Approvals

        [HttpGet("/PendingApprovals")]
        public IActionResult PendingApprovals()
        {
            return View("Manager/PendingApprovals");
        }
        #endregion

        #region Manager Reports

        [HttpGet("/ManagerReports")]
        public IActionResult ManagerReports()
        {
            return View("Manager/Reports");
        }

        #endregion

        //------------------------------
        //-X-X-X-X-X-X-X-X

        // HR

        //-X-X-X-X-X-X-X-X

        #region HR Dashboard

        [HttpGet("/HRDashboard")]
        public IActionResult HRDashboard()
        {
            return View("HRAdmin/HRDashboard");
        }
        #endregion

        #region Approval Status

        [HttpGet("/ApprovalStatus")]
        public IActionResult ApprovalStatus()
        {
            return View("HRAdmin/ApprovalStatus");
        }

        #endregion

        #region Assign Approver

        [HttpGet("/AssignApprover")]
        public IActionResult AssignApprover()
        {
            return View("HRAdmin/AssignApprover");
        }
        #endregion

        #region Engagement Status

        [HttpGet("/EngagementStatus")]
        public IActionResult EngagementStatus()
        {
            return View("HRAdmin/EngagementStatus");
        }
        #endregion

        #region Assign Delegate

        [HttpGet("/AssignDelegate")]
        public IActionResult AssignDelegate()
        {
            return View("HRAdmin/AssignDelegate");
        }

        #endregion

        //------------------------------
        //-X-X-X-X-X-X-X-X

        // EMPLOYEE

        //-X-X-X-X-X-X-X-X

        #region Employee Dashboard

        [HttpGet("/MyDashboard")]
        public IActionResult MyDashboard()
        {
            return View("Employee/MyDashboard");
        }

        #endregion

        #region Employee Engagements

        [HttpGet("/MyEngagements")]
        public IActionResult MyEngagements()
        {
            return View("Employee/MyEngagements");
        }

        #endregion

        #region New Timesheet

        [HttpGet("/NewTimesheet")]
        public IActionResult NewTimesheet()
        {
            return View("Employee/NewTimesheet");
        }

        #endregion

        #region Previous Timesheets

        [HttpGet("/PreviousTimesheets")]
        public IActionResult PreviousTImesheets()
        {
            return View("Employee/PreviousTimesheets");
        }
        #endregion

        //------------------------------
        //-X-X-X-X-X-X-X-X

        // DELEGATE

        //-X-X-X-X-X-X-X-X

        #region Delegate Pending Approval

        [HttpGet("/DelegatePendingApprovals")]
        public IActionResult DelegatePendingApprovals() 
        {
            return View("Delegate/DelegationPendingApproval");
        }

        #endregion


        //------------------------------
        //-X-X-X-X-X-X-X-X

        // SuperUser

        //-X-X-X-X-X-X-X-X

        [HttpGet("/OrganizationStructure")]
        public IActionResult OrganizationalStructure()
        {
            return View("SuperUser/OrganizationalStructure");
        }


        [HttpGet]
        public IActionResult hb()
        {
            var username = UserSession.GetUserName(HttpContext);
            if (username == null)
            {
                return Json(new { ok = false, username = "" });
            }

            return Json(new
            {
                ok = true,
                username = username,
                isTimeout = false
            });
        }
    }
}
