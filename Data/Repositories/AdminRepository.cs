using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace UCITMS.Data.Repositories
{
    public class AdminRepository : IAdminRepository
    {
        #region Dependency Injection

        private readonly string _connectionString;
        private IConfiguration _configuration;

        public AdminRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }

        #endregion

        #region Get Admin Dashboard Info

        public async Task<List<GetAdminDashboardInfoDTO>> GetDashboardInfoAsync()
        {
            var dashboardInfoList = new List<GetAdminDashboardInfoDTO>();

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("dbo.AdminDashboardInfo", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            dashboardInfoList.Add(new GetAdminDashboardInfoDTO
                            {
                                CategoryId = reader.GetInt32(reader.GetOrdinal("CategoryId")),
                                CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                                Key = reader.GetString(reader.GetOrdinal("Key")),
                                Value = reader.GetInt32(reader.GetOrdinal("Value"))
                            });
                        }
                    }
                }
            }

            return dashboardInfoList;
        }
        #endregion

        #region Get System User Info

        public async Task<List<GetSystemUserDTO>> GetAllSystemUsersAsync()
        {
            var users = new List<GetSystemUserDTO>();

            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("[dbo].[GetAllSystemUsers]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    await connection.OpenAsync();
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {

                            users.Add(new GetSystemUserDTO
                            {
                                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                DisplayName = reader.GetString(reader.GetOrdinal("DisplayName")),
                                Email = reader.GetString(reader.GetOrdinal("Email")),
                                ModifiedBy = reader["ModifiedByName"] as string,
                                ModifiedOn = reader["ModifiedOn"] as DateTime?,
                                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                                EmployeeID = reader["EmployeeID"] as string,
                                LocationID = reader["LocationID"] as int?,
                                LocationName = reader["LocationName"] as string,
                                DepartmentID = reader["DepartmentID"] as int?,
                                DepartmentName = reader["DepartmentName"] as string,
                                UserRoles = reader.IsDBNull(reader.GetOrdinal("UserRoles")) ? new List<int>() : reader.GetString(reader.GetOrdinal("UserRoles")).Split(',').Select(int.Parse).ToList(),
                                UserRoleName = reader.IsDBNull(reader.GetOrdinal("UserRoleName")) ? new List<string>() : reader.GetString(reader.GetOrdinal("UserRoleName")).Split(',').ToList()
                            });
                        }
                    }
                }
            }

            return users;
        }

        #endregion

        #region Post System User Info

        public async Task<string> UpdateSystemUserAsync(PostSystemUserDTO user)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[dbo].[UpdateSystemUser]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Add parameters
                    command.Parameters.AddWithValue("@UserID", user.UserID);
                    command.Parameters.AddWithValue("@IsActive", user.IsActive);
                    command.Parameters.AddWithValue("@EmployeeID", user.EmployeeID);
                    command.Parameters.AddWithValue("@Location", user.LocationID);
                    command.Parameters.AddWithValue("@Department", user.DepartmentID);
                    command.Parameters.AddWithValue("@NewRoles", user.Roles);
                    command.Parameters.AddWithValue("@ModifiedBy", user.ModUser);

                    await connection.OpenAsync();
                    int rowsAffected = await command.ExecuteNonQueryAsync();
                    return "User data updated successfully";
                }
            }
        }

        #endregion

        #region Get engagements for admin
        public async Task<List<GetEngagementForAdminDTO>> GetEngagementsForAdmin()
        {
            var engagements = new List<GetEngagementForAdminDTO>();

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("GetEngagementsForAdmin", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            engagements.Add(new GetEngagementForAdminDTO
                            {
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                Title = reader.IsDBNull(reader.GetOrdinal("Title")) ? null : reader.GetString(reader.GetOrdinal("Title")),
                                Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                                StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                EndDate = reader.IsDBNull(reader.GetOrdinal("EndDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                EngagementScopeID = reader.IsDBNull(reader.GetOrdinal("EngagementScopeID")) ? null : reader.GetInt32(reader.GetOrdinal("EngagementScopeID")),
                                ModifiedOn = reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                                ModifiedBy = reader.IsDBNull(reader.GetOrdinal("DisplayName")) ? null : reader.GetString(reader.GetOrdinal("DisplayName"))
                            });
                        }
                    }
                }
            }

            return engagements;
        }
        #endregion

        #region Update engagement scope
        public async Task<bool> UpdateEngagementScope(PostEngagementForAdminDTO engagement)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("UpdateEngagementScope", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.Add(new SqlParameter("@EngagementID", SqlDbType.Int) { Value = engagement.EngagementID });
                    command.Parameters.Add(new SqlParameter("@NewEngagementScopeID", SqlDbType.Int) { Value = engagement.EngagementScopeID });
                    command.Parameters.AddWithValue("@ModifiedBy", engagement.ModifiedBy);

                    await connection.OpenAsync();
                    var result = await command.ExecuteNonQueryAsync();
                    return result > 0;
                }
            }
        }
        #endregion
    }
}
