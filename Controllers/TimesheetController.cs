using Azure.Core;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration.UserSecrets;
using System.Net;
using System.Reflection;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Controllers
{
    [Route("api/timesheet")]
    [ApiController]
    public class TimesheetController : Controller
    {
        #region Dependency Injection
        private readonly ITimesheetRepository _timesheetRepository;
        private readonly INotificationRepository _notificationRepository;
        private IAuthorizationRepository _authorizationRepository;
        private IHelperRepository _helperRepository;
        public TimesheetController(ITimesheetRepository timesheetRepository, 
            INotificationRepository notificationRepository,
            IAuthorizationRepository authorizationRepository,
            IHelperRepository helperRepository)
        {
            _timesheetRepository = timesheetRepository;
            _notificationRepository = notificationRepository;
            _authorizationRepository = authorizationRepository;
            _helperRepository = helperRepository;
        }
        #endregion

        #region Get Timesheet Data
        //Note: we are passing userid just for testing purpose. we'll remove it after integrating with UI

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]
        [HttpGet] 
        public async Task<IActionResult> GetTimesheetData()
        {
            int userId = (int)UserSession.GetUserId(HttpContext);

          

            var timesheet = await _timesheetRepository.GetTimesheetData(userId);

            if (timesheet == null)
                return Ok(new { data = (object)null });

            return Ok(new { data = timesheet });
        }
        #endregion

        #region Add or Update Timesheet Lines   

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]
        [HttpPost("save")] 
        public async Task<IActionResult> AddOrUpdateTimesheetLine([FromBody] PostTimesheetLineDTO timesheetEntry)
        {
            try
            {
                int userId = (int)UserSession.GetUserId(HttpContext);

                if (!_authorizationRepository.TimesheetAccess(AutherizationType.AddEditTimesheetLine, timesheetEntry.TimesheetID, userId))
                {
                    return Unauthorized(new { error = "You are not authorized to make changes to this timesheet!" });
                }
                if (timesheetEntry.LineID != null)
                {
                    if (!_authorizationRepository.TimesheetAccess(AutherizationType.EditTimesheetLineId, timesheetEntry.TimesheetID, (int)timesheetEntry.LineID))
                    {
                        return Unauthorized(new { error = "You are not authorized to make changes to this timesheet!" });
                    }
                }
                

                if (!_authorizationRepository.TimesheetAccess(AutherizationType.AddTimesheetTask, timesheetEntry.TaskID, userId))
                {
                    return Unauthorized(new { error = "You are not authorized to make changes to this timesheet!" });
                }

                if (timesheetEntry == null)
                {
                    return BadRequest(new { error = "Timesheet entry is null." });
                }

                if ((timesheetEntry.Hours == 0 && timesheetEntry.Minutes == 0) || timesheetEntry.Hours < 0 || timesheetEntry.Minutes < 0 || timesheetEntry.Minutes >= 60 || timesheetEntry.Minutes % 5 != 0) 
                {
                    return BadRequest(new { error = "Please enter valid time." });
                }

                timesheetEntry.Comment = _helperRepository.StripAndEncodeHTML(timesheetEntry.Comment);

                timesheetEntry.ModUser = userId;

                var lineID = await _timesheetRepository.AddOrUpdateTimesheetLineAsync(timesheetEntry);

                return Ok(new { LineID = lineID });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500,new { error = ex.Message });
            }
        }

        #endregion

        #region Delete Timesheet Line

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]
        [HttpDelete("{lineID}")]
        public async Task<IActionResult> DeleteTimesheetLine(int lineID)
        {
            if (lineID <= 0)
            {
                return BadRequest("Invalid LineID.");
            }

            int userId = (int)UserSession.GetUserId(HttpContext);
            if (!_authorizationRepository.TimesheetAccess(AutherizationType.DeleteTimesheetLine, lineID, userId))
            {
                return Unauthorized("You are not authorized to make changes to this timesheet!");

            }
            var result = await _timesheetRepository.DeleteTimesheetLineAsync(lineID);
            if (result == "Record deleted successfully.")
            {
                return Ok(new { Message = result });
            }
            else
            {
                return NotFound(new { Message = result });
            }
        }
        #endregion

        #region Submit Timesheet for Approval
        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]
        [HttpPost("Submit")]
        public async Task<IActionResult> SubmitForApproval([FromBody] PostTimesheetHdrDTO timesheetHdr)
        {
            if (timesheetHdr == null)
            {
                return BadRequest("Invalid timesheet data.");
            }

            int userId = (int)UserSession.GetUserId(HttpContext);

            #region Check User Permission
            if (!_authorizationRepository.TimesheetAccess(AutherizationType.SubmitTimesheet, 
                timesheetHdr.TimesheetID, userId))
            {
                return Unauthorized("You are not authorized to perform this operation!");

            }
            #endregion

            timesheetHdr.SubmissionComment = _helperRepository.StripAndEncodeHTML(timesheetHdr.SubmissionComment);

            timesheetHdr.UserID = userId;

            var result = await _timesheetRepository.SubmitTimesheetForApprovalAsync(timesheetHdr);
            return Ok(new { Result = result });
        }

        #endregion

        #region Approve timesheet

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Pending_Approval)]
        [HttpPost("Approve")]
        public async Task<IActionResult> ApproveTimesheet([FromBody] PostApproveTimesheetDTO timesheetApproval)
        {
            if (timesheetApproval == null || timesheetApproval.TimesheetID <= 0)
            {
                return BadRequest("Invalid timesheet data.");
            }
            int moduser = (int)UserSession.GetUserId(HttpContext);
            if (!_authorizationRepository.TimesheetAccess(AutherizationType.ReviewTimesheet, timesheetApproval.TimesheetID, moduser))
            {
                return Unauthorized("You are not authorized to make changes to this timesheet!");

            }

            timesheetApproval.ApprovalComment = _helperRepository.StripAndEncodeHTML(timesheetApproval.ApprovalComment);

            timesheetApproval.ModUser = moduser;
            var result = await _timesheetRepository.ApproveTimesheetAsync(timesheetApproval);
            return Ok(new { Result = result });
        }
        #endregion

        #region Get Pending Timesheet for Approval

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Pending_Approval)]
        [HttpGet("GetPendingTimesheets")]
        public async Task<IActionResult> GetPendingApprovalTimesheets()
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            var timesheets = await _timesheetRepository.GetPendingApprovalTimesheets(userId);

            if (timesheets == null || !timesheets.Any())
            {
                return Ok(new { data = (object)null });
            }

            return Ok(new { data = timesheets });
        }

        #endregion

        #region Get Timesheet by TimesheetID

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]
        [HttpGet("{timesheetID}")]
        public async Task<IActionResult> GetTimesheetLinesByTimesheetID(int timesheetID)
        {
            int userId = (int)UserSession.GetUserId(HttpContext);

            if (!_authorizationRepository.TimesheetAccess(AutherizationType.ReadTimesheet, timesheetID, userId))
            {
                return Unauthorized("You are not authorized to view this timesheet!");

            }

            var timesheetLines = await _timesheetRepository.GetTimesheetLinesByTimesheetIDAsync(timesheetID);
            return Ok(timesheetLines);
        }
        #endregion

        #region Get Approved Timesheets

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Approved_Timesheets)]

        [HttpGet("approved")]
        public async Task<IActionResult> GetApprovedTimesheets()
        {
            int userId = (int)UserSession.GetUserId(HttpContext);

            var timesheets = await _timesheetRepository.GetApprovedTimesheetsAsync(userId);

            if (timesheets == null || !timesheets.Any())
            {
                return Ok(new { data = (object)null });
            }

            return Ok(new { data = timesheets });
        }

        #endregion

        #region Get Timesheet Drop-dpown Data on Add new timesheet page

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Add_new_Timesheet)]
        [HttpGet("ddr")]
        public async Task<IActionResult> GetTimesheetDropDownData()
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            var timesheet = await _timesheetRepository.GetTimesheetDropdown(userId);

            if (timesheet == null)
                return NotFound($"No timesheet found for UserID: {userId}.");

            return Ok(timesheet);
        }
        #endregion

        #region Get Previous Timesheets

        [AppAuthorizationFilter(AutherizationType.Menu, Item.View_Previous_Timesheets)]

        [HttpGet("previous")]
        public async Task<IActionResult> GetPreviousTimesheets()
        {
            int userId = (int)UserSession.GetUserId(HttpContext);

            var timesheets = await _timesheetRepository.GetPreviousTimesheetsAsync(userId);

            if (timesheets == null || !timesheets.Any())
            {
                return Ok(new { data = (object)null });
            }

            return Ok(new { data = timesheets });
        }

        #endregion

        #region Send Approval Email
        [AllowAnonymous]
        [HttpGet("sendemail")]
        public IActionResult SendApprovarEmail()
        {
            try
            {
                _notificationRepository.SendApprovalEmails();
                
                return Ok(true);
            }
            catch (Exception ex) {
              return BadRequest(ex.Message);


            }

        }
        [AllowAnonymous]
        [HttpPost("sendemail")]
        public async Task<IActionResult> postApprovarEmail()
        {
            try
            {
                _notificationRepository.SendApprovalEmails();

                return Ok(true);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);

            }

        }
        [AllowAnonymous]
        [HttpPost("TriggerEmail")]
        public async Task<IActionResult> TriggerEmail()
        {
            try
            {
                _notificationRepository.SendApprovalEmails();

                return Ok(true);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);

            }

        }
        #endregion

        //#region Send RejectionEmail Email
        //[HttpGet("sendRejectEmail/{TimesheetId}")]
        //public void sendRejectEmail([FromRoute] int TimesheetId=0)
        //{
        //    _notificationRepository.SendTimesheetRejectEmail(TimesheetId);
        //}
        //#endregion

        #region Reject timesheet

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Pending_Approval)]
        [HttpPost("Reject")]
        public async Task<IActionResult> RejectTimesheet([FromBody] PostRejectTimesheetDTO timesheetRejection)
        {
            if (timesheetRejection == null || timesheetRejection.TimesheetID <= 0)
            {
                return BadRequest("Invalid timesheet data.");
            }

            int moduser = (int)UserSession.GetUserId(HttpContext);


            if (!_authorizationRepository.TimesheetAccess(AutherizationType.ReviewTimesheet, timesheetRejection.TimesheetID, moduser))
            {
                return Unauthorized("You are not authorized to make changes to this timesheet!");

            }

            timesheetRejection.RejectionComment = _helperRepository.StripAndEncodeHTML(timesheetRejection.RejectionComment);

            timesheetRejection.ModUser = moduser;

            var result = await _timesheetRepository.RejectTimesheetAsync(timesheetRejection);

            // Start the email sending process as a separate task
            Task.Run(() => _notificationRepository.SendTimesheetRejectEmail(timesheetRejection.TimesheetID));

            return Ok(new { Result = result });
        }

        #endregion

        #region Get Timesheet Comments for Manager

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Pending_Approval)]
        [HttpGet("gettimesheetcomments")]
        public async Task<IActionResult> GetTimesheetComments([FromQuery] int timesheetId)
        {
            #region Check User Permission
            int userId = (int)UserSession.GetUserId(HttpContext);
            if (!_authorizationRepository.TimesheetAccess(AutherizationType.ReadTimesheet,
                timesheetId, userId))
            {
                return Unauthorized("You are not authorized to perform this operation!");

            }
            #endregion


            var commentsInfo = await _timesheetRepository.GetTimesheetCommentsAsync(timesheetId);
            return Ok(commentsInfo);
        }


        #endregion

        #region Get Timesheet Comments for Employee

        [AppAuthorizationFilter(AutherizationType.Menu, Item.View_Previous_Timesheets)]
        [HttpGet("getvptimesheetcomments")]
        public async Task<IActionResult> GetVPTimesheetComments([FromQuery] int timesheetId)
        {
            #region Check User Permission
            int userId = (int)UserSession.GetUserId(HttpContext);
            if (!_authorizationRepository.TimesheetAccess(AutherizationType.ReadTimesheet,
                timesheetId, userId))
            {
                return Unauthorized("You are not authorized to perform this operation!");

            }
            #endregion


            var commentsInfo = await _timesheetRepository.GetTimesheetCommentsAsync(timesheetId);
            return Ok(commentsInfo);
        }


        #endregion


        #region Test

        [AllowAnonymous]
        [HttpGet("Test")]
        public IActionResult Test()
        {
            string msg = "";
            NotificationDTO _dto = new NotificationDTO();
            _dto.to = "ritesh@uciny.com";
            _dto.body = "<b>Hello World</b>";
            _dto.subject = "TEST CALL";
            _dto.EmailCategory = "TEST";

            try
            {
                _notificationRepository.SendMail(_dto);
                msg = "done";
            }
            catch (Exception ex) {
                msg = ex.ToString();
            }
            return Ok(msg);
        }

        #endregion
    }
}