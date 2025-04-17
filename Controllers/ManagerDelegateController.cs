using Microsoft.AspNetCore.Mvc;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Data.Repositories;
using UCITMS.Models;

namespace UCITMS.Controllers
{
    [ApiController]
    [Route("api/Delegate")]
    public class ManagerDelegateController : Controller
    {
        private readonly IManagerDelegateRepository _managerDelegateRepository;

        #region Constructor

        public ManagerDelegateController(IManagerDelegateRepository managerDelegateRepository)
        {
            _managerDelegateRepository = managerDelegateRepository;
        }

        #endregion

        #region GET API for AssignDelegate

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Assign_Delegate)]
        [HttpGet]
        public async Task<IActionResult> GetAllManagerDelegateInfo()
        {
            List<GetManagerDelegateDTO> managerDelegateInfo = await _managerDelegateRepository.GetManagerDelegateInfoAsync();
            return Ok(managerDelegateInfo);
        }


        #endregion

        #region POST API for AssignDelegate

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Assign_Delegate)]
        [HttpPost("save")]
        public async Task<IActionResult> AddOrUpdateDelegates([FromBody] PostManagerDelegateDTO managerdelegate)
        {
            managerdelegate.ModUser = UserSession.GetUserId(HttpContext);
            
            string msg = await _managerDelegateRepository.AddOrUpdateDelegatesAsync(managerdelegate);
            return Ok(msg);

        }

        #endregion

        #region Get API for All Managers List

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Assign_Delegate)]
        [HttpGet("getallmanagers")]
        public async Task<IActionResult> GetAllManagersInfo()
        {
            List<GetAllManagersDTO> managersInfo = await
                _managerDelegateRepository.GetAllManagersInfoAsync();
            return Ok(managersInfo);
        }

        #endregion


    }
}
