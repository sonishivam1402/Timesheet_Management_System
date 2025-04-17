using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models; 

namespace UCITMS.Data.Repositories
{
    public class TimesheetRepository : ITimesheetRepository
    {
        #region Dependency Injection
        private readonly string _connectionString;
        private IConfiguration _configuration;
        public TimesheetRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }
        #endregion

        #region Get Timesheet Data
        public async Task<GetTimesheetHdrDTO> GetTimesheetData(int userId)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("GetTimesheet", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", userId);

                    await connection.OpenAsync();

                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        GetTimesheetHdrDTO timesheet = null;

                        #region Read the timesheet header details
                        if (await reader.ReadAsync())
                        {
                            timesheet = new GetTimesheetHdrDTO
                            {
                                TimesheetID = reader.GetInt32(reader.GetOrdinal("TimesheetID")),
                                StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                Status = reader.GetInt32(reader.GetOrdinal("Status")),
                                HoursTotal = reader.GetInt32(reader.GetOrdinal("TotalHours")),
                                MinutesTotal = reader.GetInt32(reader.GetOrdinal("TotalMinutes")),
                                TimesheetLines = new List<GetTimesheetLineDTO>()
                            };
                        }

                        // Move to the next result set for timesheet lines, if any
                        if (timesheet != null && await reader.NextResultAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var line = new GetTimesheetLineDTO
                                {
                                    LineID = reader.GetInt32(reader.GetOrdinal("LineID")),
                                    TimesheetID = reader.GetInt32(reader.GetOrdinal("TimesheetID")),
                                    EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                    TaskID = reader.GetInt32(reader.GetOrdinal("TaskID")),
                                    Hours = reader.GetInt32(reader.GetOrdinal("Hours")),
                                    Minutes = reader.GetInt32(reader.GetOrdinal("Minutes")),
                                    Date = reader.GetDateTime(reader.GetOrdinal("Date")),
                                    Comment = reader.IsDBNull(reader.GetOrdinal("Comment")) ? "" : reader.GetString(reader.GetOrdinal("Comment"))
                                };

                                timesheet.TimesheetLines.Add(line);
                            }
                        }
                        #endregion
                        return timesheet;
                    }
                }
            }
        }
        #endregion

        #region Add or Update Timesheet Line
        public async Task<int> AddOrUpdateTimesheetLineAsync(PostTimesheetLineDTO timesheetEntry)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("AddOrUpdateTimesheetLine", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    #region Add Parameters
                    command.Parameters.AddWithValue("@LineID", timesheetEntry.LineID.HasValue ? (object)timesheetEntry.LineID.Value : DBNull.Value);
                    command.Parameters.AddWithValue("@TimesheetID", timesheetEntry.TimesheetID);
                    command.Parameters.AddWithValue("@EngagementID", timesheetEntry.EngagementID);
                    command.Parameters.AddWithValue("@TaskID", timesheetEntry.TaskID);
                    command.Parameters.AddWithValue("@Hours", timesheetEntry.Hours);
                    command.Parameters.AddWithValue("@Minutes", timesheetEntry.Minutes);
                    command.Parameters.AddWithValue("@Date", timesheetEntry.Date);
                    command.Parameters.AddWithValue("@Comment", string.IsNullOrEmpty(timesheetEntry.Comment) ? (object)DBNull.Value : timesheetEntry.Comment);
                    command.Parameters.AddWithValue("@ModUser", timesheetEntry.ModUser.HasValue ? (object)timesheetEntry.ModUser.Value : DBNull.Value);
                    #endregion

                    await connection.OpenAsync();

                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        // Check if the first result set has data
                        if (await reader.ReadAsync())
                        {
                            // Check if the result contains a status and message
                            if (reader.FieldCount == 2)
                            {
                                int status = reader.GetInt32(0);
                                string message = reader.GetString(1);

                                if (status == -1)
                                {
                                    throw new InvalidOperationException(message); // Return the error message
                                }
                            }
                            else if (reader.FieldCount == 1)
                            {
                                // This should be the LineID (new or updated)
                                return reader.GetInt32(0);
                            }
                        }
                    }
                    throw new InvalidOperationException("Unexpected result from stored procedure.");
                }
            }
        }


        #endregion

        #region Delete Timesheet Line
        public async Task<string> DeleteTimesheetLineAsync(int lineID)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("DeleteTimesheetLine", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@LineID", lineID);

                    connection.Open();
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        if (reader.Read())
                        {
                            return reader["Message"].ToString();
                        }
                        else
                        {
                            return "No response from database.";
                        }
                    }
                }
            }
        }
        #endregion

        #region Submit for Approval
        public async Task<string> SubmitTimesheetForApprovalAsync(PostTimesheetHdrDTO timesheetHdr)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("SubmitTimesheetForApproval", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    #region Add parameters
                    command.Parameters.AddWithValue("@TimesheetID", timesheetHdr.TimesheetID);
                    command.Parameters.AddWithValue("@UserID", timesheetHdr.UserID);
                    command.Parameters.AddWithValue("@SubmissionComment",
                                            string.IsNullOrEmpty(timesheetHdr.SubmissionComment) ? (object)DBNull.Value : timesheetHdr.SubmissionComment);
                    #endregion

                    await connection.OpenAsync();
                        await command.ExecuteNonQueryAsync();
                        return "Timesheet submitted successfully.";
                }
            }
        }
        #endregion


        #region Approve Timesheet
        public async Task<int> ApproveTimesheetAsync(PostApproveTimesheetDTO timesheetApproval)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("ApproveTimesheet", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    #region Add Parameters
                    command.Parameters.AddWithValue("@TimesheetID", timesheetApproval.TimesheetID);
                    command.Parameters.AddWithValue("@ApprovalComment",
                        string.IsNullOrEmpty(timesheetApproval.ApprovalComment) ? (object)DBNull.Value : timesheetApproval.ApprovalComment);
                    command.Parameters.AddWithValue("@ModUser", timesheetApproval.ModUser);
                    #endregion

                    await connection.OpenAsync();

                    // Execute the command and retrieve the number of rows affected
                    var result = await command.ExecuteNonQueryAsync();
                    return result;
                }
            }
        }
        #endregion


        #region Get Pending Timesheets for Approval

        public async Task<List<GetApprovalTimesheetsDTO>> GetPendingApprovalTimesheets(int userId)
        {
            var timesheets = new List<GetApprovalTimesheetsDTO>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("dbo.GetPendingApprovalTimesheets", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ManagerID", userId);

                    await conn.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            timesheets.Add(new GetApprovalTimesheetsDTO
                            {
                                TimesheetID = reader.GetInt32(reader.GetOrdinal("TimesheetID")),
                                EmployeeName = reader.GetString(reader.GetOrdinal("EmployeeName")),
                                StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                Hours = reader.GetInt32(reader.GetOrdinal("HoursTotal")),
                                Minutes = reader.GetInt32(reader.GetOrdinal("MinutesTotal")),
                                SubmissionComment = reader.IsDBNull("SubmissionComment") ? null : reader.GetString("SubmissionComment"),
                                SubmittedOn = reader.GetDateTime(reader.GetOrdinal("SubmittedOn")),
                                DisplayTitle = reader.GetString(reader.GetOrdinal("DisplayTitle")),
                                CommentsCount = reader.GetInt32(reader.GetOrdinal("CommentsCount"))
                            });
                        }
                    }
                }
            }

            return timesheets;
        }

        #endregion

        #region Get Timesheet by TimesheetID
        public async Task<IEnumerable<GetTimesheetLineDTO>> GetTimesheetLinesByTimesheetIDAsync(int timesheetID)
        {
            var timesheetLines = new List<GetTimesheetLineDTO>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("GetTimesheetLinesByTimesheetID", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TimesheetID", timesheetID);

                    await connection.OpenAsync();
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var entry = new GetTimesheetLineDTO
                            {
                                LineID = reader.GetInt32(reader.GetOrdinal("LineID")),
                                TimesheetID = reader.GetInt32(reader.GetOrdinal("TimesheetID")),
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                EngagementName = reader.GetString(reader.GetOrdinal("EngagementName")),
                                TaskID = reader.GetInt32(reader.GetOrdinal("TaskID")),
                                TaskName = reader.GetString(reader.GetOrdinal("TaskName")),
                                Hours = reader.GetInt32(reader.GetOrdinal("Hours")),
                                Minutes = reader.GetInt32(reader.GetOrdinal("Minutes")),
                                Date = reader.GetDateTime(reader.GetOrdinal("Date")),
                                Comment = reader.IsDBNull(reader.GetOrdinal("Comment")) ? null : reader.GetString(reader.GetOrdinal("Comment")),
                            };
                            timesheetLines.Add(entry);   
                        }
                    }
                }
            }

            return timesheetLines;
        }
        #endregion

        #region Get Approved Timesheets

        public async Task<List<GetApprovedTimesheets>> GetApprovedTimesheetsAsync(int userID)
        {
            var approvedTimesheets = new List<GetApprovedTimesheets>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("[dbo].[GetApprovedTimesheets]", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ManagerID", userID);

                    conn.Open();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            approvedTimesheets.Add(new GetApprovedTimesheets
                            {
                                TimesheetID = reader.GetInt32("TimesheetID"),
                                EmployeeName = reader.GetString("EmployeeName"),
                                StartDate = reader.GetDateTime("StartDate"),
                                EndDate = reader.GetDateTime("EndDate"),
                                HoursTotal = reader.GetInt32("HoursTotal"),
                                MinutesTotal = reader.GetInt32("MinutesTotal"),
                                SubmittedOn = reader.IsDBNull("SubmittedOn") ? (DateTime?)null : reader.GetDateTime("SubmittedOn"),
                                SubmissionComment = reader.IsDBNull("SubmissionComment") ? null : reader.GetString("SubmissionComment"),
                                ApprovedOn = reader.IsDBNull("ApprovedOn") ? (DateTime?)null : reader.GetDateTime("ApprovedOn"),
                                ApprovalComment = reader.IsDBNull("ApprovalComment") ? null : reader.GetString("ApprovalComment"),
                                ApprovedBy = reader.GetString("ApprovedBy"),
                                DisplayTitle = reader.GetString("DisplayTitle"),
                                CommentsCount = reader.GetInt32("CommentsCount")
                            });
                        }
                    }
                }
            }
            return approvedTimesheets;
        }

        #endregion

        #region Get Timesheet DropDown
        public async Task<List<GetTimesheetHdrDTO>> GetTimesheetDropdown(int userId)
        {
            var UnapprovedTimesheets = new List<GetTimesheetHdrDTO>();
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("GetTimesheetsDropDown", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", userId);

                    await connection.OpenAsync();

                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        #region Read the timesheet header details
                        while (await reader.ReadAsync())
                        {
                            UnapprovedTimesheets.Add(new GetTimesheetHdrDTO
                            {
                                TimesheetID = reader.GetInt32(reader.GetOrdinal("TimesheetID")),
                                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                Status = reader.GetInt32(reader.GetOrdinal("Status")),
                                HoursTotal = reader.GetInt32(reader.GetOrdinal("HoursTotal")),
                                MinutesTotal = reader.GetInt32(reader.GetOrdinal("MinutesTotal")),
                                DisplayTitle = reader.GetString(reader.GetOrdinal("DisplayTitle"))
                            });
                        }
                        #endregion
                        
                        return UnapprovedTimesheets;
                    }
                }
            }
        }
        #endregion

        #region Get Previous Timesheets

        public async Task<List<GetPreviousTimesheets>> GetPreviousTimesheetsAsync(int userID)
        {
            var previousTimesheets = new List<GetPreviousTimesheets>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("[dbo].[GetEmployeePreviousTimesheets]", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@UserID", userID);

                    conn.Open();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            previousTimesheets.Add(new GetPreviousTimesheets
                            {
                                TimesheetID = reader.GetInt32("TimesheetID"),
                                StartDate = reader.GetDateTime("StartDate"),
                                EndDate = reader.GetDateTime("EndDate"),
                                Status = reader.GetInt32("Status"),
                                HoursTotal = reader.GetInt32("TotalHours"),
                                MinutesTotal = reader.GetInt32("TotalMinutes"),
                                SubmittedOn = reader.IsDBNull("SubmittedOn") ? (DateTime?)null : reader.GetDateTime("SubmittedOn"),
                                SubmissionComment = reader.IsDBNull("SubmissionComment") ? null : reader.GetString("SubmissionComment"),
                                ApprovedOn = reader.IsDBNull("ApprovedOn") ? (DateTime?)null : reader.GetDateTime("ApprovedOn"),
                                ApprovalComment = reader.IsDBNull("ApprovalComment") ? null : reader.GetString("ApprovalComment"),
                                ApprovedBy = reader.IsDBNull("ApprovedBy") ? null : reader.GetString("ApprovedBy"),
                                DisplayTitle = reader.GetString("DisplayTitle"),
                                CommentsCount = reader.GetInt32("CommentsCount")
                            });
                        }
                    }
                }
            }
            return previousTimesheets;
        }

        #endregion

        #region Reject Timesheet
        public async Task<int> RejectTimesheetAsync(PostRejectTimesheetDTO timesheetRejection)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("RejectTimesheet", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    #region Add Parameters
                    command.Parameters.AddWithValue("@TimesheetID", timesheetRejection.TimesheetID);
                    command.Parameters.AddWithValue("@RejectionComment",
                        string.IsNullOrEmpty(timesheetRejection.RejectionComment) ? (object)DBNull.Value : timesheetRejection.RejectionComment);
                    command.Parameters.AddWithValue("@ModUser", timesheetRejection.ModUser);
                    #endregion

                    await connection.OpenAsync();

                    // Execute the command and retrieve the number of rows affected
                    var result = await command.ExecuteNonQueryAsync();
                    return result;
                }
            }
        }    
        #endregion

        #region Get Timesheet Comments

        public async Task<List<GetTimesheetCommentsDTO>> GetTimesheetCommentsAsync(int timesheetId)
        {
            var comments = new List<GetTimesheetCommentsDTO>();
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using(SqlCommand cmd = new SqlCommand("dbo.GetWorkflowData", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@TimesheetId", timesheetId);

                    await conn.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            comments.Add(new GetTimesheetCommentsDTO
                            {
                                TimesheetId = reader.GetInt32(reader.GetOrdinal("TimesheetId")),
                                CommentType = reader.GetInt32(reader.GetOrdinal("CommentType")),
                                CommentTypeText = reader.GetString(reader.GetOrdinal("CommentTypeText")),
                                CommentText = reader.GetString(reader.GetOrdinal("CommentText")),
                                CommentDate = reader.GetDateTime(reader.GetOrdinal("CommentDate")),
                                CommentBy = reader.GetInt32(reader.GetOrdinal("CommentBy")),
                                CommentByUser = reader.GetString(reader.GetOrdinal("CommentByUser"))


                            });
                        }
                    }
                }
            }
            return comments;
        }

        #endregion
    }
}