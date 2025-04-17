using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System;
using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace UCITMS.Data.Repositories
{
    public class EngagementRepository : IEngagementRepository
    {
        #region Variables and constructor

        private string _connectionString;
        private IConfiguration _configuration;
        public EngagementRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString= _configuration.GetConnectionString("connectionString");
        }

        #endregion

        #region Save Engagement

        public async Task<int> SaveEngagementAsync(PostEngagementDTO engagement)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.AddOrUpdateEngagement", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // Add parameters
                cmd.Parameters.AddWithValue("@EngagementID", engagement.EngagementID);
                cmd.Parameters.AddWithValue("@Title", engagement.Title);
                cmd.Parameters.AddWithValue("@StartDate", engagement.StartDate);
                cmd.Parameters.AddWithValue("@EndDate", engagement.EndDate);
                cmd.Parameters.AddWithValue("@Description", engagement.Description ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@ModUser", engagement.ModUser ?? (object)DBNull.Value);

                // Table-valued parameters for team members, tasks, and owners
                SqlParameter teamMembersParam = cmd.Parameters.AddWithValue("@TeamMembers", CreateTeamMemberDataTable(engagement.TeamMembers));
                teamMembersParam.SqlDbType = SqlDbType.Structured;
                teamMembersParam.TypeName = "dbo.TeamMemberType";

                SqlParameter tasksParam = cmd.Parameters.AddWithValue("@Tasks", CreateTaskDataTable(engagement.Tasks));
                tasksParam.SqlDbType = SqlDbType.Structured;
                tasksParam.TypeName = "dbo.TaskType";

                // Add parameter for engagement owners
                SqlParameter ownersParam = cmd.Parameters.AddWithValue("@EngagementOwners", CreateOwnerDataTable(engagement.Owners));
                ownersParam.SqlDbType = SqlDbType.Structured;
                ownersParam.TypeName = "dbo.EngagementOwnerType";

                await conn.OpenAsync();

                var result = await cmd.ExecuteScalarAsync();
                return int.TryParse(result?.ToString(), out int engagementId) ? engagementId : 0;
            }
        }
        
        #endregion

        #region Create Team Member Data Table

        private DataTable CreateTeamMemberDataTable(List<TeamMemberDTO> teamMembers)
        {
            DataTable table = new DataTable();
            table.Columns.Add("UserID", typeof(int));
            table.Columns.Add("StartDate", typeof(DateTime));
            table.Columns.Add("EndDate", typeof(DateTime));
            table.Columns.Add("MaxWeeklyHours", typeof(int));

            foreach (var member in teamMembers)
            {
                table.Rows.Add(member.UserID, member.StartDate, member.EndDate, member.MaxWeeklyHours);
            }

            return table;
        }

        #endregion

        #region Create Task Data Table

        private DataTable CreateTaskDataTable(List<PostTaskDTO> tasks)
        {
            DataTable table = new DataTable();
            table.Columns.Add("TaskID", typeof(int));

            foreach (var task in tasks)
            {
                table.Rows.Add(task.TaskID);
            }

            return table;
        }

        #endregion

        #region Create Owner Data Table

        private DataTable CreateOwnerDataTable(List<OwnerDTO> owners)
        {
            DataTable table = new DataTable();
            table.Columns.Add("UserID", typeof(int));  

            foreach (var owner in owners)
            {
                table.Rows.Add(owner.UserID);
            }

            return table;
        }

        #endregion

        #region Get All Engagement
        public async Task<List<GetEngagementDTO>> GetAllEngagements()
        {
            var engagements = new List<GetEngagementDTO>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetEngagementDetails", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@EngagementID", DBNull.Value); // Passing NULL to get all engagements

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    // Reading engagements
                    while (reader.Read())
                    {
                        var engagement = new GetEngagementDTO
                        {
                            EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                            Title = reader.GetString(reader.GetOrdinal("Title")),
                            StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                            EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                            Description = reader["Description"]?.ToString(),
                            IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive"))
                        };

                        engagements.Add(engagement);
                    }

                    #region Move to the second result set (tasks)
                    if (reader.NextResult())
                    {
                        while (reader.Read())
                        {
                            var task = new GetTaskDTO
                            {
                                EngagementTaskID = reader.GetInt32(reader.GetOrdinal("EngagementTaskID")),
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                TaskID = reader.GetInt32(reader.GetOrdinal("TaskID")),
                                TaskName = reader["TaskName"]?.ToString(),
                                TaskDescription = reader["TaskDescription"]?.ToString(),
                            };

                            var engagement = engagements.FirstOrDefault(e => e.EngagementID == reader.GetInt32(reader.GetOrdinal("EngagementID")));
                            if (engagement != null)
                            {
                                engagement.Tasks.Add(task);
                            }
                        }
                    }
                    #endregion

                    #region Move to the third result set (team members)
                    if (reader.NextResult())
                    {
                        while (reader.Read())
                        {
                            var teamMember = new TeamMemberDTO
                            {
                                MappingID = reader.GetInt32(reader.GetOrdinal("MappingID")),
                                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                TeamMemberName = reader["TeamMemberName"]?.ToString(),
                                StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                EndDate = reader.IsDBNull(reader.GetOrdinal("EndDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                MaxWeeklyHours = reader.GetInt32(reader.GetOrdinal("MaxWeeklyHours")),
                                CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("CreatedBy")),
                                ModifiedBy = reader.IsDBNull(reader.GetOrdinal("ModifiedBy")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("ModifiedBy")),
                                CreatedOn = reader.IsDBNull(reader.GetOrdinal("CreatedOn")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("CreatedOn")),
                                ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID"))
                            };

                            var engagement = engagements.FirstOrDefault(e => e.EngagementID == reader.GetInt32(reader.GetOrdinal("EngagementID")));
                            if (engagement != null)
                            {
                                engagement.TeamMembers.Add(teamMember);
                            }
                        }
                    }
                    #endregion

                    #region Move to the fourth result set (owners)
                    if (reader.NextResult())
                    {
                        while (reader.Read())
                        {
                            var owner = new OwnerDTO
                            {
                                MappingID = reader.GetInt32(reader.GetOrdinal("MappingID")),
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                OwnerName = reader["OwnerName"]?.ToString()
                            };

                            var engagement = engagements.FirstOrDefault(e => e.EngagementID == owner.EngagementID);
                            if (engagement != null)
                            {
                                engagement.Owners.Add(owner);
                            }
                        }
                    }
                    #endregion
                }
            }

            return engagements;
        }

        #endregion

        #region Get Engagement By ID

        public GetEngagementDTO GetEngagementById(int engagementId)
        {
            GetEngagementDTO engagement = null;

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetEngagementDetails", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@EngagementID", engagementId);

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    // Reading engagement details
                    if (reader.Read())
                    {
                        engagement = new GetEngagementDTO
                        {
                            EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                            Title = reader.GetString(reader.GetOrdinal("Title")),
                            StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                            EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                            Description = reader["Description"]?.ToString()
                        };
                    }

                    #region Move to the second result set (tasks)
                    if (reader.NextResult())
                    {
                        while (reader.Read())
                        {
                            var task = new GetTaskDTO
                            {
                                EngagementTaskID = reader.GetInt32(reader.GetOrdinal("EngagementTaskID")),
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                TaskID = reader.GetInt32(reader.GetOrdinal("TaskID")),
                                TaskName = reader["TaskName"]?.ToString(),
                                TaskDescription = reader["TaskDescription"]?.ToString()
                            };

                            engagement.Tasks.Add(task);
                        }
                    }
                    #endregion

                    #region Move to the third result set (team members)
                    if (reader.NextResult())
                    {
                        while (reader.Read())
                        {
                            var teamMember = new TeamMemberDTO
                            {
                                MappingID = reader.GetInt32(reader.GetOrdinal("MappingID")),
                                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                TeamMemberName = reader["TeamMemberName"]?.ToString(),
                                StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                EndDate = reader.IsDBNull(reader.GetOrdinal("EndDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                MaxWeeklyHours = reader.GetInt32(reader.GetOrdinal("MaxWeeklyHours")),
                                CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("CreatedBy")),
                                ModifiedBy = reader.IsDBNull(reader.GetOrdinal("ModifiedBy")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("ModifiedBy")),
                                CreatedOn = reader.IsDBNull(reader.GetOrdinal("CreatedOn")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("CreatedOn")),
                                ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID"))
                            };

                            engagement.TeamMembers.Add(teamMember);
                        }
                    }
                    #endregion

                    #region Move to the fourth result set (owners)
                    if (reader.NextResult())
                    {
                        while (reader.Read())
                        {
                            var owner = new OwnerDTO
                            {
                                MappingID = reader.GetInt32(reader.GetOrdinal("MappingID")),
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                OwnerName = reader["OwnerName"]?.ToString()
                            };

                            if (engagement != null)
                            {
                                engagement.Owners.Add(owner);
                            }
                        }
                    }
                    #endregion
                }
            }

            return engagement;
        }

        #endregion

        #region Get Engagement By UserID

        public async Task<List<GetEngagementDTO>> GetEngagementsByUserIdAsync(int? userId)
        {
            var engagements = new List<GetEngagementDTO>();
            var tasks = new List<GetTaskDTO>();
            var teamMembers = new List<TeamMemberDTO>();
            var owners = new List<OwnerDTO>();

            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand("GetEngagementsByUserID", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@CreatedBy", userId.HasValue ? (object)userId.Value : DBNull.Value);

                try
                {
                    await connection.OpenAsync();

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // Reading engagements
                        while (await reader.ReadAsync())
                        {
                            var engagement = new GetEngagementDTO
                            {
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                Title = reader.GetString(reader.GetOrdinal("Title")),
                                StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                Description = reader["Description"]?.ToString()
                            };

                            engagements.Add(engagement);
                        }

                        #region Read Tasks
                        if (await reader.NextResultAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var task = new GetTaskDTO
                                {
                                    EngagementTaskID = reader.GetInt32(reader.GetOrdinal("EngagementTaskID")),
                                    EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                    TaskID = reader.GetInt32(reader.GetOrdinal("TaskID")),
                                    TaskName = reader["TaskName"] as string ?? string.Empty,
                                    TaskDescription = reader["TaskDescription"] as string ?? string.Empty
                                };

                                tasks.Add(task);
                            }
                        }
                        #endregion

                        #region Read Team Members
                        if (await reader.NextResultAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var teamMember = new TeamMemberDTO
                                {
                                    MappingID = reader.GetInt32(reader.GetOrdinal("MappingID")),
                                    EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                    UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                    TeamMemberName = reader["TeamMemberName"] as string ?? string.Empty,
                                    StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                    EndDate = reader.IsDBNull(reader.GetOrdinal("EndDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                    MaxWeeklyHours = reader.IsDBNull(reader.GetOrdinal("MaxWeeklyHours")) ? 0 : reader.GetInt32(reader.GetOrdinal("MaxWeeklyHours")),
                                    CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("CreatedBy")),
                                    ModifiedBy = reader.IsDBNull(reader.GetOrdinal("ModifiedBy")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("ModifiedBy")),
                                    ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                                    CreatedOn = reader.IsDBNull(reader.GetOrdinal("CreatedOn")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("CreatedOn"))
                                };

                                teamMembers.Add(teamMember);
                            }
                        }

                        #endregion

                        #region Read Owners
                        if (await reader.NextResultAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var owner = new OwnerDTO
                                {
                                    MappingID = reader.GetInt32(reader.GetOrdinal("MappingID")),
                                    EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                    UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                    OwnerName = reader["OwnerName"] as string ?? string.Empty
                                };

                                owners.Add(owner);
                            }
                        }
                        #endregion
                    }

                    foreach (var engagement in engagements)
                    {
                        engagement.Tasks = tasks.Where(t => t.EngagementID == engagement.EngagementID).ToList();
                        engagement.TeamMembers = teamMembers.Where(tm => tm.EngagementID == engagement.EngagementID).ToList();
                        engagement.Owners = owners.Where(o => o.EngagementID == engagement.EngagementID).ToList();
                    }
                }
                catch (Exception ex)
                {
                    throw new ApplicationException("An error occurred while fetching engagements, tasks, team members, and owners.", ex);
                }
            }

            return engagements;
        }

        #endregion

        #region Get Engagement for Timesheet

        public List<GetEngagementDTO> GetEngagementsByUserAndDate(int userId, DateTime date)
        {
            List<GetEngagementDTO> engagements = new List<GetEngagementDTO>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("GetUserEngagementDetails", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@Date", date);

                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var engagement = new GetEngagementDTO
                            {
                                EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                Title = reader.GetString(reader.GetOrdinal("Title")),
                                //StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                //EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                Description = reader["Description"]?.ToString()
                            };

                            engagements.Add(engagement);
                        }
                    }
                }
            }

            return engagements;
        }

        #endregion

        #region Get Engagement for Employees

        public async Task<IEnumerable<GetAllEngagementsDTO>> GetEngagementsforEmployeeAsync(int? id)
        {
            if (!id.HasValue)
            {
                return new List<GetAllEngagementsDTO>();
            }

            var engagements = new List<GetAllEngagementsDTO>();

            
                using (var connection = new SqlConnection(_connectionString))
                {
                    using (var command = new SqlCommand("dbo.GetEngagementsForEmployee", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.Add("@UserId", SqlDbType.Int).Value = id.Value;

                        await connection.OpenAsync();

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var engagement = new GetAllEngagementsDTO
                                {
                                    EngagementID = reader.GetInt32(reader.GetOrdinal("EngagementID")),
                                    Title = reader.IsDBNull(reader.GetOrdinal("Title")) ? null : reader.GetString(reader.GetOrdinal("Title")),
                                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                                    Owners = reader.IsDBNull(reader.GetOrdinal("Owners")) ? null : reader.GetString(reader.GetOrdinal("Owners")),
                                    StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                    EndDate = reader.IsDBNull(reader.GetOrdinal("EndDate")) ? null : reader.GetDateTime(reader.GetOrdinal("EndDate")),
                                    TeamMembers = reader.IsDBNull(reader.GetOrdinal("TeamMembers")) ? null : reader.GetString(reader.GetOrdinal("TeamMembers")),
                                };
                                engagements.Add(engagement);
                            }
                        }
                    }
                }

            return engagements;
        }

        #endregion

        #region Get tasks by Engagement Id

        public List<GetTaskDTO> GetTasksByEngagementId(int engagementId)
        {
            List<GetTaskDTO> tasks = new List<GetTaskDTO>();
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand command = new SqlCommand("GetTasksByEngagementId", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@EngagementID", engagementId);

                connection.Open();
                SqlDataReader reader = command.ExecuteReader();
                while (reader.Read())
                {
                    GetTaskDTO task = new GetTaskDTO
                    {
                        EngagementID = (int)reader["EngagementID"],
                        TaskID = (int)reader["TaskID"],
                        TaskName = reader["TaskName"].ToString()
                    };
                    tasks.Add(task);
                }
            }
            return tasks;
        }

        #endregion

        #region Delete Enagagement
        public DeleteEngagementResponse DeleteEngagement(int engagementId, int userId)
        {
            DeleteEngagementResponse response = new DeleteEngagementResponse();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("DeleteEngagement", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EngagementId", engagementId);
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            response.CanDelete = reader.GetBoolean(reader.GetOrdinal("CanDelete"));
                            response.Message = reader.GetString(reader.GetOrdinal("Message"));
                        }
                    }
                }
            }

            return response;
        }

        #endregion
    }
}