using Microsoft.AspNetCore.Mvc;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Data.Repositories;

namespace UCITMS.Controllers
{
    [Route("api/notification")]
    [ApiController]
    public class NotificationController : Controller
    {
        #region Dependency Injection
        private readonly INotificationRepository _notificationRepository;
        private IAuthorizationRepository _authorizationRepository;


        public NotificationController(INotificationRepository notificationRepository, IAuthorizationRepository authorizationRepository)
        {
            _notificationRepository = notificationRepository;
            _authorizationRepository = authorizationRepository;
        }
        #endregion

        #region Get notification count
        [HttpGet("count")]
        public IActionResult GetNotificationCount()
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            int count = _notificationRepository.GetNotificationCount(userId);
            return Ok(new { NotificationCount = count });
            
        }
        #endregion

        #region Get User notifications
        [HttpGet]
        public async Task<IActionResult> GetNotificationsAsync()
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            var notifications = await _notificationRepository.GetNotificationsAsync(userId);
            return Ok(notifications);
            
        }
        #endregion

        #region Mark notification as inactive
        [HttpPost("inactive/{recordId}")]
        public async Task<IActionResult> MarkNotificationAsInactiveAsync(int recordId)
        {
            int modUser = (int)UserSession.GetUserId(HttpContext);

            if (!_authorizationRepository.TimesheetAccess(AutherizationType.InactivateNotification, recordId, modUser))
            {
                return Unauthorized("You are not authorized to mark as inactive to this notification!");

            }

            bool result = await _notificationRepository.MarkNotificationAsInactiveAsync(recordId, modUser);
            if (result)
            {
                return Ok(new { Message = "Notification marked as inactive." });
            }
            return NotFound(new { Message = "Notification not found." });
            
        }
        #endregion

        #region Mark notification as Read
        [HttpPost("read")]
        public async Task<IActionResult> MarkNotificationsAsReadAsync()
        {
            int UserId = (int)UserSession.GetUserId(HttpContext);
            bool result = await _notificationRepository.MarkNotificationsAsReadAsync(UserId);
            if (result)
            {
                return Ok(new { Message = "All Notifications marked as read." });
            }
            return Ok(new { Message = "No Unread Notifications found." });

        }
        #endregion
    }
}
