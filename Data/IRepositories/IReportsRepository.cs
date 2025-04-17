using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IReportsRepository
    {
        Task<List<ReportsDTO>> GetManagerReportAsync(int ManagerId);

        Task<List<ReportsSchemaDTO>> GetReportsSchemaAsync(int ID);
    }
}
