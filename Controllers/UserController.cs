using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        #region Dependency Injection

        private readonly IUserRepository _userRepository;

        public UserController(IUserRepository userService)
        {
            _userRepository = userService;
        }

        #endregion

        #region Get All Users

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_My_Engagements)]

        [HttpGet("GetAllUsers")]
        public async Task<ActionResult<List<UserDTO>>> GetAllUsers()
        {
            int currentUserId = (int)UserSession.GetUserId(HttpContext);
            var users = await _userRepository.GetAllUsers();
            if (users == null || users.Count == 0)
            {
                return NotFound("No users found.");
            }
            return Ok(new { CurrentUserID = currentUserId, Users = users });
        }

        #endregion

        #region Get Current User Info

        [HttpGet("GetCurrentUserInfo")]
        public IActionResult GetCurrentUserInfo()
        {
            UserDTO userInfo = new UserDTO();
            userInfo.Username = UserSession.GetUserName(HttpContext);
            userInfo.Email = UserSession.GetUserEmail(HttpContext);
            userInfo.EnvVar = UserSession.GetEnvVar(HttpContext);

            if (userInfo.Username == null && userInfo.Email == null)
            {
                return NotFound();
            }

            return Ok(userInfo);
        }

        #endregion
    }
}
