using Microsoft.AspNetCore.Mvc;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SuperUserController : Controller
    {
        #region Dependency Injection

        private readonly ISuperUserRepository _superUserRepository;

        public SuperUserController(ISuperUserRepository superUserRepository)
        {
            _superUserRepository = superUserRepository;
        }

        #endregion

        #region Get Organizational Structure Data

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Employee_Dashboard)]
        [HttpGet("GetOrgData")]
        public async Task<ActionResult<List<SuperUserDTO>>> GetSuperUserInfo()
        {
            List<SuperUserDTO> result = await _superUserRepository.GetSuperUserInfo();
            return Ok(result);
        }

        #endregion
    }
}
