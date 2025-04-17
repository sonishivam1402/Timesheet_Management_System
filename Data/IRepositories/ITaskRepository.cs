using Microsoft.AspNetCore.Mvc;
using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface ITaskRepository
    {
        #region Get All Tasks
        Task<List<GetTaskDTO>> GetAllTasksAsync();
        #endregion

        #region Get Task By ID
        Task<GetTaskDTO> GetTaskByIdAsync(int id);
        #endregion

        #region Add or Update Task
        Task<int> AddOrUpdateTask(PostTaskDTO task);
        #endregion

        #region Delete task
        DeleteTaskResponse DeleteTask(int taskId, int userId);
        #endregion
    }
}
