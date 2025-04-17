using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using Microsoft.Data.SqlClient;

namespace UCITMS.Data.Repositories
{
    public class DashboardRepository : IDashboardRepository
    {
        #region Dependency Injection
        private readonly string _connectionString;
        private IConfiguration _configuration;
        private readonly IHRAdminRepository _hRAdminRepository;
        private readonly IManagerDelegateRepository _managerDelegateRepository;

        public DashboardRepository(IConfiguration configuration, IHRAdminRepository hRAdminRepository, IManagerDelegateRepository managerDelegateRepository)
        {
            _hRAdminRepository = hRAdminRepository;
            _managerDelegateRepository = managerDelegateRepository;
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");

        }
        #endregion

        #region For Employee Dashboard

        #region Last TS Date
        public async Task<GetEmpDashboardDTO> GetLastTSDateAndDefaultsAsync(int? id)
        {
            GetEmpDashboardDTO empDashData = new GetEmpDashboardDTO();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("[dbo].[GetLastTimesheetDate]", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@UserID", id);

                await connection.OpenAsync();
                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        empDashData.LastTSDate = reader.GetString(reader.GetOrdinal("LastTSDate"));
                        if(empDashData.LastTSDate == "2024-01-01")
                        {
                            empDashData.LastTSDate = "No Submissions";
                        }
                    }
                }
            }
            return empDashData;
        }
        #endregion

        #region Primary & Secondary Approvers
        public async Task<GetUserManagerDTO> GetUserApproverInfoAsync(int? id)
        {
            List<GetUserManagerDTO> allInfo = await _hRAdminRepository.GetUserManagerInfoAsync();

            GetUserManagerDTO empDashData = allInfo.FirstOrDefault(user => user.UserID == id);

            // If empDashData is null, return a new object with default messages

            return empDashData ?? new GetUserManagerDTO
            {
                PrimaryManagerName = "Not assigned",
                SecondaryManagerName = "Not assigned"
            };
        }
        #endregion

        #region Get Employee defaults 
        public async Task<List<GetEmpDefaultsDTO>> GetEmployeeDefaults(int? userId)
        {
            var defaultsList = new List<GetEmpDefaultsDTO>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetDefaulters", conn);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", userId);

                await conn.OpenAsync();

                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var timesheet = new GetEmpDefaultsDTO
                        {
                            TimesheetDuration = reader.GetString(reader.GetOrdinal("Duration"))
                        };
                        defaultsList.Add(timesheet);
                    }
                }
            }

            return defaultsList;
        }
        #endregion

        #endregion

        #region For Manager Dashboard

        #region Pending Approval Count
        public async Task<GetPendingApprovalCountDTO> GetPendingApprovalCountAsync(int? id)
            {
                GetPendingApprovalCountDTO mgrDashData = new GetPendingApprovalCountDTO();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand cmd = new SqlCommand("dbo.GetPendingApprovals", connection);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserID", id);

                    await connection.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            mgrDashData.PendingApprovals = reader.GetInt32(reader.GetOrdinal("TotalCount"));
                        }
                    }
                }
                return mgrDashData;
            }
            #endregion

            #region Managed Users
            public async Task<List<GetManagedUsersDTO>> GetAllManagedUsersAsync(int? userId)
                {
                    var userList = new List<GetManagedUsersDTO>();

                    using (SqlConnection conn = new SqlConnection(_connectionString))
                    {
                        SqlCommand cmd = new SqlCommand("dbo.GetManagedUsers", conn);
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@ManagerID", userId);

                        await conn.OpenAsync();

                        using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var user = new GetManagedUsersDTO
                                {
                                    UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                    Username = reader.GetString(reader.GetOrdinal("DisplayName")),
                                    IsPrimary = reader.GetBoolean(reader.GetOrdinal("isPrimary")),
                                    IsSecondary = reader.GetBoolean(reader.GetOrdinal("isSecondary"))
                                };
                                userList.Add(user);
                            }
                        }
                    }

                    return userList;
                }
            #endregion

            #region Delegate Time Span
        public async Task<GetDelegateTimeSpanDTO> GetDelegateTimeSpanInfoAsync(int? id)
        {
            GetDelegateTimeSpanDTO mgrDashData = new GetDelegateTimeSpanDTO();
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetDelegateForManager", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ManagerId", id);

                await connection.OpenAsync();
                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync()) 
                    {
                        mgrDashData.DelegateTimeSpan = reader.GetString(reader.GetOrdinal("DelegateTimeSpan"));
                        if (string.IsNullOrEmpty(mgrDashData.DelegateTimeSpan))
                        {
                            mgrDashData.DelegateTimeSpan = "Not Assigned";
                        }
                    }
                }
            }
            mgrDashData.DelegateTimeSpan = mgrDashData.DelegateTimeSpan ?? "Not Assigned";
            return mgrDashData;
        }

        #endregion

            #region Get Delegate Info

        public async Task<GetManagerDelegateDTO> GetDelegateInfoAsync(int? id)
        {
            List<GetManagerDelegateDTO> allInfo = await
                _managerDelegateRepository.GetManagerDelegateInfoAsync();
           
            GetManagerDelegateDTO mgrDashData = allInfo.FirstOrDefault(user => user.ManagerID == id);
            if (mgrDashData == null)
            {
                mgrDashData = new GetManagerDelegateDTO
                {
                    DelegateName = "Not Assigned",
                    StartDate = DateTime.Parse("01/01/2024"),
                    EndDate = DateTime.Parse("01/01/2024")
                };
            }

            return mgrDashData;
        }

        #endregion

            #region Get Manager Defaulters

            public async Task<List<GetManagerDefaulterDTO>> GetManagerDefaulterInfoAsync(int? userId)
            {
                var userList = new List<GetManagerDefaulterDTO>();

                using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetDefaulters", conn);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add(new SqlParameter("@ManagerId", userId));

                await conn.OpenAsync();

                using (SqlDataReader reader = await cmd.ExecuteReaderAsync()) 
                {
                    while (await reader.ReadAsync())
                    {
                        var user = new GetManagerDefaulterDTO
                        {
                            ManagerId = reader.GetInt32(reader.GetOrdinal("ManagerId")),
                            UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                            Manager = reader.GetString(reader.GetOrdinal("Manager")),
                            User = reader.GetString(reader.GetOrdinal("User")),
                            Duration = reader.GetString(reader.GetOrdinal("Duration")),
                            StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                            hasDraft = reader.GetBoolean(reader.GetOrdinal("hasDraft")),
                            hasSubmitted = reader.GetBoolean(reader.GetOrdinal("hasSubmitted")),
                            hasDefaulted = reader.GetBoolean(reader.GetOrdinal("hasDefaulted"))
                        };
                        userList.Add(user);
                    }
                }

            }
                return userList;
            }

            #endregion

        #endregion

        #region For HR Dashboard

        #region Get Defaulter Count
        public async Task<GetDefaulterCountDTO> GetTotalDefaultersAsync()
            {
                GetDefaulterCountDTO hrDashData = new GetDefaulterCountDTO();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand cmd = new SqlCommand("dbo.GetTotalDefaulters", connection);
                    cmd.CommandType = CommandType.StoredProcedure;

                    await connection.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            hrDashData.DefaultersCount = reader.GetInt32(reader.GetOrdinal("TotalDefaulterCount"));
                        }
                    }
                }
                return hrDashData;
            }
            #endregion

            #region Get User COUNT with NoApprover
            public async Task<UsersNoApproverCountDTO> GetCountNoApproverAsync()
            {
                var counts = new UsersNoApproverCountDTO();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand cmd = new SqlCommand("dbo.GetUsersWithoutApprovers", connection);
                    cmd.CommandType = CommandType.StoredProcedure;
                    await connection.OpenAsync();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        #region Fetch Count Data
                        if (await reader.NextResultAsync() && await reader.ReadAsync())
                        {
                            counts.NoApproverCount = reader.GetInt32(reader.GetOrdinal("Users_Without_PA"));
                        }

                        if (await reader.NextResultAsync() && await reader.ReadAsync())
                        {
                            counts.NoSecApproverCount = reader.GetInt32(reader.GetOrdinal("Users_Without_SA"));
                        }

                        #endregion
                    }
                }
                return counts;
            }
            #endregion

        #endregion


    }
}
