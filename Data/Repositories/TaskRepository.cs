using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace UCITMS.Data.Repositories
{
    public class TaskRepository: ITaskRepository
    {
        #region Variables and Constructors
        private string _connectionString;
        private IConfiguration _configuration;

        public TaskRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }
        #endregion

        #region Get All Tasks

        // Retrieve all tasks
        public async Task<List<GetTaskDTO>> GetAllTasksAsync()
        {
            var tasks = new List<GetTaskDTO>();

            using (var connection = new SqlConnection(_connectionString))
            {
                SqlCommand command = new SqlCommand("GetTasks", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                await connection.OpenAsync();

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var task = new GetTaskDTO
                        {
                            TaskID = reader.GetInt32(reader.GetOrdinal("TaskID")),
                            TaskName = reader.GetString(reader.GetOrdinal("TaskName")),
                            TaskDescription = reader.GetString(reader.GetOrdinal("TaskDescription")),
                            IsDeleted = reader.GetBoolean(reader.GetOrdinal("IsDeleted")),
                            IsGeneric = reader.GetBoolean(reader.GetOrdinal("IsGeneric")),
                            CreatedBy = reader.GetString(reader.GetOrdinal("CreatedByName")),
                            CreatedOn = reader.GetDateTime(reader.GetOrdinal("CreatedOn")),
                            ModifiedBy = reader.GetString(reader.GetOrdinal("ModifiedByName")),
                            ModifiedOn = reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                        };
                        tasks.Add(task);
                    }
                }
            }

            return tasks;
        }
        #endregion

        #region Get Task By Id

        // Retrieve a task by ID
        public async Task<GetTaskDTO> GetTaskByIdAsync(int id)
        {
            GetTaskDTO task = null;

            using (var connection = new SqlConnection(_connectionString))
            {
                SqlCommand command = new SqlCommand("GetTaskByID", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };
                command.Parameters.AddWithValue("@TaskID", id);
                await connection.OpenAsync();

                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        task = new GetTaskDTO
                        {
                            TaskID = reader.GetInt32(reader.GetOrdinal("TaskID")),
                            TaskName = reader.GetString(reader.GetOrdinal("TaskName")),
                            TaskDescription = reader.GetString(reader.GetOrdinal("TaskDescription")),
                            IsDeleted = reader.GetBoolean(reader.GetOrdinal("IsDeleted")),
                            IsGeneric = reader.GetBoolean(reader.GetOrdinal("IsGeneric")),
                        };
                    }
                }
            }

            return task;
        }
        #endregion

        #region Add or Update Task
        public async Task<int> AddOrUpdateTask(PostTaskDTO task)
        {
            int taskId;

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("dbo.AddOrUpdateTask", conn))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@TaskID", task.TaskID == 0 ? (object)DBNull.Value : task.TaskID);
                    command.Parameters.AddWithValue("@TaskName", task.TaskName);
                    command.Parameters.AddWithValue("@TaskDescription", task.TaskDescription ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@IsDeleted", task.IsDeleted);
                    command.Parameters.AddWithValue("@IsGeneric", task.IsGeneric);
                    command.Parameters.AddWithValue("@ModUser", task.ModUser);

                    SqlParameter outputIdParam = new SqlParameter("@NewTaskID", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(outputIdParam);

                    await conn.OpenAsync();
                    await command.ExecuteNonQueryAsync();

                    taskId = Convert.ToInt32(outputIdParam.Value);
                }
            }

            return taskId;
        }
        #endregion

        #region Delete Task
        public DeleteTaskResponse DeleteTask(int taskId, int userId)
        {
            DeleteTaskResponse response = new DeleteTaskResponse();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("DeleteTask", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@TaskId", taskId);
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
