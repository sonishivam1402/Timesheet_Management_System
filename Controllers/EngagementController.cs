using Azure;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Reflection;
using System.Threading.Tasks;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Data.Repositories;
using UCITMS.Models;

namespace UCITMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EngagementController : ControllerBase
    {
        #region Data Repositories
        
        private readonly IEngagementRepository _engagementRepository;
        private readonly ITaskRepository _taskRepository;
        private readonly IUserRepository _userRepository;
        private IAuthorizationRepository _authorizationRepository;
        private IHelperRepository _helperRepository;
        #endregion

        #region Constructor Injection
        public EngagementController(IEngagementRepository engagementRepository, ITaskRepository taskRepository, IUserRepository userRepository, IAuthorizationRepository authorizationRepository, IHelperRepository helperRepository)
        {
            _engagementRepository = engagementRepository;
            _taskRepository = taskRepository;
            _userRepository = userRepository;
            _authorizationRepository = authorizationRepository;
            _helperRepository = helperRepository;
        }
        #endregion

        #region Engagement Management

        #region Save an engagement

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_My_Engagements)]
        [HttpPost("Save")]
        public async Task<IActionResult> SaveEngagement([FromBody] PostEngagementDTO engagement)
        {
            engagement.ModUser = UserSession.GetUserId(HttpContext);

            #region Check User Permission
            if (!_authorizationRepository.TimesheetAccess(AutherizationType.SaveEngagement,
                engagement.EngagementID,(int) engagement.ModUser))
            {
                return Unauthorized("You are not authorized to perform this operation!");

            }
            #endregion

            engagement.Title = _helperRepository.StripAndEncodeHTML(engagement.Title);
            engagement.Description = _helperRepository.StripAndEncodeHTML(engagement.Description);

            if (string.IsNullOrEmpty(engagement.Title) || string.IsNullOrEmpty(engagement.Description) || engagement.Title.Contains(','))
            {
                return BadRequest("Invalid input!");
            }

            int engagementId = await _engagementRepository.SaveEngagementAsync(engagement);
            return Ok(new { EngagementID = engagementId });
        }
        #endregion

        #region Get all engagements

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Active_Engagements)]
        [HttpGet]
        public async Task<ActionResult<List<GetEngagementDTO>>> GetAllEngagements()
        {
            var engagements = await _engagementRepository.GetAllEngagements();
            if (engagements == null)
            {
                return NotFound("No engagements found.");
            }
            return Ok(engagements);
        }
        #endregion

        #region Get engagement by owner
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_My_Engagements)]
        [HttpGet("owner")]
        public async Task<IActionResult> GetEngagementByOwner()
        {
            var userId = UserSession.GetUserId(HttpContext);
            var engagements = (await _engagementRepository.GetAllEngagements()).Where(e => e.Owners.Any(o => o.UserID == userId)).ToList();
            return Ok(engagements);
        }
        #endregion

        #region Get engagement by user and date

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]

        [HttpGet("GetEngagementsByUserAndDate/{date}")]
        public IActionResult GetEngagementsByUserAndDate([FromRoute] DateTime date)
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            List<GetEngagementDTO> engagements = _engagementRepository.GetEngagementsByUserAndDate(userId, date);

            if (engagements == null || engagements.Count == 0)
            {
                return NotFound("No engagements found for the given user and date.");
            }

            return Ok(engagements);
        }
        #endregion
        
        #region Get Engagements for Employee

        [AppAuthorizationFilter(AutherizationType.Menu, Item.My_Engagements)]

        [HttpGet("myengagements")]
        public async Task<ActionResult<IEnumerable<GetAllEngagementsDTO>>> GetEngagementsforEmployee()
        {
            int Userid = (int)UserSession.GetUserId(HttpContext);
            var engagements = await _engagementRepository.GetEngagementsforEmployeeAsync(Userid);
             
             if (engagements == null || !engagements.Any())
             {
                 return NotFound("No engagements found for the specified User.");
             }
             
             return Ok(engagements);
        }
        #endregion

        #endregion

        #region Task Management

        #region Get all tasks
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_My_Engagements)]
        [HttpGet("tasks")]
        public async Task<ActionResult<TaskResponseDTO>> GetAllTasks()
        {
            var username = UserSession.GetUserName(HttpContext);
            var tasks = await _taskRepository.GetAllTasksAsync();
            if (tasks == null || !tasks.Any())
            {
                return NotFound("No tasks found.");
            }
            var response = new TaskResponseDTO
            {
                UserName = username,
                Tasks = tasks
            };

            return Ok(response);
        }
        #endregion

        #region Get task by task id

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]
        [HttpGet("tasks/{id}")]
        public async Task<ActionResult<GetTaskDTO>> GetTaskById(int id)
        {
            var task = await _taskRepository.GetTaskByIdAsync(id);
            if (task == null)
            {
                return NotFound($"Task with ID {id} not found.");
            }
            return Ok(task);
        }
        #endregion

        #region Get Tasks by engagement id

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]
        [HttpGet("{id}")]
        public ActionResult<GetEngagementDTO> GetTasksbyEngagementId(int id)
        {
            int Userid = (int)UserSession.GetUserId(HttpContext);

            #region Check User Permission
            if (!_authorizationRepository.TimesheetAccess(AutherizationType.ViewEngagement,
                id, Userid))
            {
                return Unauthorized("You are not authorized to view this Engagement!");

            }
            #endregion

            var engagement = _engagementRepository.GetTasksByEngagementId(id);
            if (engagement == null)
            {
                return NotFound($"Engagement with ID {id} not found.");
            }
            return Ok(engagement);
        }
        #endregion

        #region Add or Update Task

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_My_Engagements)]
        [HttpPost("tasks")]
        public async Task<IActionResult> AddOrUpdateTask([FromBody] PostTaskDTO task)
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            task.ModUser = userId;

            if (string.IsNullOrEmpty(task.TaskName) || task.TaskName.Contains(","))
            {
                return BadRequest(new {message = "Invalid task name"});
            }

            task.TaskName = _helperRepository.StripAndEncodeHTML(task.TaskName);
            task.TaskDescription = _helperRepository.StripAndEncodeHTML(task.TaskDescription);

            // Execute add or update depending on TaskID value
            int taskId = await _taskRepository.AddOrUpdateTask(task);
            if(taskId == -1)
            {
                return BadRequest(new { TaskID = taskId });
            }
            return Ok(new { TaskID = taskId });
        }

        #endregion

        #region Delete task

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Manage_My_Engagements)]
        [HttpDelete("tasks/{id}")]
        public IActionResult SoftDeleteTask(int id)
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            var response =  _taskRepository.DeleteTask(id, userId);

            if (response.CanDelete)
            {
                return Ok(new { message = response.Message });
            }
            else
            {
                return BadRequest(new { message = response.Message });
            }
        }
        #endregion

        #endregion

        #region Delete engagement
        [HttpDelete("DeleteEngagement/{engagementId}")]
        public IActionResult DeleteEngagement(int engagementId)
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            var response = _engagementRepository.DeleteEngagement(engagementId, userId);

            if (response.CanDelete)
            {
                return Ok(new { message = response.Message });
            }
            else
            {
                return BadRequest(new { message = response.Message });
            }
        }

        #endregion

    }
}
