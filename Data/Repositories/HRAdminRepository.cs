using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using Microsoft.Data.SqlClient;
using System.Reflection.PortableExecutable;


namespace UCITMS.Data.Repositories
{
    public class HRAdminRepository : IHRAdminRepository
    {
        #region Dependency Injection
        private readonly string _connectionString;
        private IConfiguration _configuration;
        public HRAdminRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");

        }
        #endregion

        #region Get All Users
        public async Task<List<UsersListDTO>> GetAllUsers()
        {
            var userList = new List<UsersListDTO>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("GetUsers", conn)
                {
                    CommandType = CommandType.StoredProcedure
                };

                await conn.OpenAsync();

                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var user = new UsersListDTO
                        {
                            UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                            UserName = reader.GetString(reader.GetOrdinal("DisplayName"))
                        };
                        userList.Add(user);
                    }
                }
            }

            return userList;
        }
        #endregion

        #region Save Approver Details
        public async Task<ValidateApproverDTO> AddOrUpdateApproversAsync(PostUserManagerDTO usermanager)
        {
            ValidateApproverDTO obj= new ValidateApproverDTO();

            using (var connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.AddOrUpdateApprover", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                #region Adding Parameters for SP
                cmd.Parameters.AddWithValue("@UserID", usermanager.UserID);
                cmd.Parameters.AddWithValue("@PrimaryApproverID", usermanager.PrimaryManagerID);
                cmd.Parameters.AddWithValue("@SecondaryApproverID", usermanager.SecondaryManagerID);
                cmd.Parameters.AddWithValue("@ModUserID", usermanager.ModUserID);
                #endregion

                await connection.OpenAsync();

                await cmd.ExecuteNonQueryAsync();

                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    if(await reader.ReadAsync())
                    {
                        obj.Status = reader.GetInt32(0);
                        obj.Message = reader.GetString(1);
                    }
                    else
                    {
                        obj.Status = 1;
                        obj.Message = "Add/Update Successful!";
                    }
                }
            }
            return obj;
        }
        #endregion

        #region Get Approver Details
        public async Task<List<GetUserManagerDTO>> GetUserManagerInfoAsync()
        {
            var usermanagers = new List<GetUserManagerDTO>();

            #region Conducting DB Operations
            using (var connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetUserManagerInfo", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                await connection.OpenAsync();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    #region Fetching Data
                    while (reader.Read())
                    {
                        var userID = reader.GetInt32(reader.GetOrdinal("UserID"));
                        var userName = reader.GetString(reader.GetOrdinal("UserName"));
                        var managerID = reader.GetInt32(reader.GetOrdinal("ManagerID"));
                        var managerName = reader.GetString(reader.GetOrdinal("ManagerName"));
                        var isPrimary = reader.GetBoolean(reader.GetOrdinal("isPrimary"));
                        var isSecondary = reader.GetBoolean(reader.GetOrdinal("isSecondary"));
                        var modUserName = reader.GetString(reader.GetOrdinal("ModUserName"));
                        var modifiedOn = reader.GetDateTime(reader.GetOrdinal("ModifiedOn"));

                        var existinguser = usermanagers.FirstOrDefault(u => u.UserID == userID);
                        if (existinguser == null)
                        {
                            usermanagers.Add(new GetUserManagerDTO
                            {
                                UserID = userID,
                                UserName = userName,
                                PrimaryManagerName = isPrimary ? managerName : "",
                                SecondaryManagerName = isSecondary ? managerName : "",
                                ModUserName = modUserName,
                                ModifiedOn = modifiedOn
                            });
                        }
                        else
                        {
                            if (isPrimary) existinguser.PrimaryManagerName = managerName;
                            if (isSecondary) existinguser.SecondaryManagerName = managerName;
                        }
                    }
                    #endregion
                }
            }
            #endregion

            return (usermanagers);
        }
        #endregion

        #region Get User LIST with NoApprover
        public async Task<List<UsersNoApproverListDTO>> GetListNoApproverAsync()
        {
            var result = new List<UsersNoApproverListDTO>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetUsersWithoutApprovers", connection);
                cmd.CommandType = CommandType.StoredProcedure;
                await connection.OpenAsync();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (await reader.ReadAsync())
                    {
                        #region Fetch List Data
                        var user = new UsersNoApproverListDTO();

                        user.UserID = reader.GetInt32(reader.GetOrdinal("UserID"));
                        user.UserName = reader.GetString(reader.GetOrdinal("UserName"));

                        result.Add(user);
                        #endregion
                    }
                }
            }
            return result;
        }
        #endregion

        #region Save Email Logs
        public bool SaveNotifiedEmailLog(NotifiedEmailLog model)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("SaveNotifiedEmailLog", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Add parameters
                    command.Parameters.AddWithValue("@UserID", model.UserID);
                    command.Parameters.AddWithValue("@ManagerID", model.ManagerID);
                    command.Parameters.AddWithValue("@TimesheetID", model.TimesheetID);
                    command.Parameters.AddWithValue("@SentOn", model.SentOn);

                    connection.Open();
                    var rowsAffected = command.ExecuteNonQuery();
                    return rowsAffected > 0; // Return true if at least one row was inserted
                }
            }
        }
        #endregion

        #region Get Email Logs
        public async Task<List<NotifiedEmailLogAsync>> GetNotifiedDataAsync()
        {
            var pendingTimesheets = new List<NotifiedEmailLogAsync>();

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("dbo.GetNotifiedEmailLog", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var timesheet = new NotifiedEmailLogAsync
                            {
                                TimesheetID = reader.GetInt32(reader.GetOrdinal("TimesheetID")),
                                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                UserName = reader.GetString(reader.GetOrdinal("UserName")),
                                Status = reader.GetInt32(reader.GetOrdinal("Status")),
                                tsDuration = reader.GetString(reader.GetOrdinal("tsDuration")),
                                SubmissionComment = reader.IsDBNull(reader.GetOrdinal("SubmissionComment"))? null: reader.GetString(reader.GetOrdinal("SubmissionComment")),
                            DaysDue = reader.GetInt32(reader.GetOrdinal("DaysDue")),
                                ManagerId = reader.GetInt32(reader.GetOrdinal("ManagerId")),
                                ManagerName = reader.GetString(reader.GetOrdinal("ManagerName")),
                                
                                LastNotifiedOn = reader.IsDBNull(reader.GetOrdinal("LastNotifiedOn")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("LastNotifiedOn"))
                            };

                            pendingTimesheets.Add(timesheet);
                        }
                    }
                }
            }
            return pendingTimesheets;

        }
        #endregion
    }
}