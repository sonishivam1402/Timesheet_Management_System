using Microsoft.Data.SqlClient;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Data.Repositories
{
    public class SuperUserRepository : ISuperUserRepository
    {
        private string _connectionString;
        private IConfiguration _configuration;

        public SuperUserRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");

        }

        public async Task<List<SuperUserDTO>> GetSuperUserInfo()
        {
            var result = new List<SuperUserDTO>();

            using (var connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[dbo].[GetOrgData]", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;

                    await connection.OpenAsync();

                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            result.Add(new SuperUserDTO
                            {
                                EmployeeId = reader.GetInt32(reader.GetOrdinal("EMPLOYEEID")),
                                EmployeeName = reader.GetString(reader.GetOrdinal("EMPLOYEENAME")),
                                ManagerId = reader.GetInt32(reader.GetOrdinal("MANAGERID")),
                                ManagerName = reader.GetString(reader.GetOrdinal("MANAGERNAME"))
                            });


                        }
                    }
                }
            }
            return result;

        }
    }
}
