using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Text;
using Newtonsoft.Json;
using System.Data;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Data.Repositories;
using UCITMS.Models;
namespace UCITMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        #region Dependency Injection
        private readonly IAppConfigRepository _appConfigRepository;
        private readonly IAdminRepository _adminRepository;
        private readonly IHelperRepository _helperRepository;
        public AdminController(IAppConfigRepository appConfigRepository,
            IAdminRepository adminRepository, IHelperRepository helperRepository)
        {
            _appConfigRepository = appConfigRepository;
            _adminRepository = adminRepository;
            _helperRepository = helperRepository;
        }
        #endregion

        #region Get all configurations
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Config_Settings)]
        [HttpGet("config-settings")]
        public IActionResult GetAllConfigurations()
        {
            List<GetConfigDTO> configurations = _appConfigRepository.GetAllConfigurations();
            return Ok(configurations);
        }
        #endregion

        #region Update configuration
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Config_Settings)]
        [HttpPost("config-settings")]
        public async Task<IActionResult> UpdateConfiguration([FromBody] PostConfigDTO config)
        {
            config.ModifiedBy = (int)UserSession.GetUserId(HttpContext);
            bool isUpdated = await _appConfigRepository.UpdateConfiguration(config);
            return isUpdated ? Ok("Configuration updated successfully") : NotFound();
        }
        #endregion

        #region Get Admin Dashboard Info

        [HttpGet("dashboard-info")]
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Admin_Dashboard)]
        public async Task<IActionResult> GetDashboardInfo()
        {
            var dashboardInfo = await _adminRepository.GetDashboardInfoAsync();

            if (dashboardInfo == null || dashboardInfo.Count == 0)
            {
                return NotFound(new { message = "Dashboard info not found." });
            }

            return Ok(dashboardInfo);
        }

        #endregion

        #region Get System User Info

        [HttpGet("system-user")]
        [AppAuthorizationFilter(AutherizationType.Menu, Item.System_User)]
        public async Task<IActionResult> GetAllSystemUsers()
        {
            var users = await _adminRepository.GetAllSystemUsersAsync();
            return Ok(users);
        }

        #endregion

        #region Post System User Info

        [HttpPost("updateSystemUser")]
        [AppAuthorizationFilter(AutherizationType.Menu, Item.System_User)]
        public async Task<IActionResult> UpdateSystemUser([FromBody] PostSystemUserDTO user)
        {
            int userId = (int)UserSession.GetUserId(HttpContext);

            if (user == null || user.UserID <= 0)
            {
                return Ok("Invalid user data.");
            }

            user.ModUser = userId;

            var result = await _adminRepository.UpdateSystemUserAsync(user);
            return Ok(new { Result = result });

        }

        #endregion

        #region Get all default engagements
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_Engagements)]
        [HttpGet("engagements")]
        public async Task<IActionResult> GetEngagementsForAdmin()
        {
            List<GetEngagementForAdminDTO> engagements = await _adminRepository.GetEngagementsForAdmin();
            return Ok(engagements);
        }
        #endregion

        #region Download Dashboard Info as CSV

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Admin_Dashboard)]
        [HttpGet("download-csv")]
        public async Task<IActionResult> DownloadCsv()
        {
            var dashboardInfo = await _adminRepository.GetDashboardInfoAsync();
            if (dashboardInfo == null || dashboardInfo.Count == 0)
            {
                return NotFound(new { message = "Dashboard info not found." });
            }

            var categorizedInfo = dashboardInfo.GroupBy(item => item.CategoryName).ToList();

            var csv = new StringBuilder();
            csv.AppendLine("Category,Name,Count,Percentage");

            foreach (var categoryGroup in categorizedInfo)
            {
                var categoryTotal = categoryGroup.Sum(item => item.Value);

                foreach (var item in categoryGroup)
                {
                    double value = item.Value;
                    double percentage = categoryTotal > 0 ? Math.Round((value / categoryTotal) * 100, 2) : 0;

                    csv.AppendLine($"{item.CategoryName},{item.Key},{value},{percentage}%");
                }

                csv.AppendLine();
            }

            var fileName = "Dashboard_Report.csv";
            var fileBytes = Encoding.UTF8.GetBytes(csv.ToString());
            return File(fileBytes, "text/csv", fileName);
        }

        #endregion

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_Engagements)]
        [HttpPost("engagements")]
        public async Task<IActionResult> UpdateEngagementScope([FromBody] PostEngagementForAdminDTO engagement)
        {
            engagement.ModifiedBy = (int)UserSession.GetUserId(HttpContext);
            var result = await _adminRepository.UpdateEngagementScope(engagement);
            if(result)
            {
                return Ok(new { success = true });
            }
            return BadRequest(new { success = false });
        }
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_Engagements)]
        [HttpGet("TSSumamry")]
        public IActionResult GetTimesheetSummary()
        {
            GenericCommandDTO obj=new GenericCommandDTO();
            obj.CurrentUserId= (int)UserSession.GetUserId(HttpContext);
            obj.CommandType =GenericCommandType.TimesheetCountByStatus;
            DataTable tbl= _helperRepository.GetGenericData(obj);            
            return Ok(JsonConvert.SerializeObject(tbl));
        }
    }
}
