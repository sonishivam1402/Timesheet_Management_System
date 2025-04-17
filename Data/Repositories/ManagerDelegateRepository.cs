using Microsoft.Data.SqlClient;
using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Data.Repositories
{
    public class ManagerDelegateRepository : IManagerDelegateRepository
    {
        #region Variables and Constructors
        
        private string _connectionString;
        private IConfiguration _configuration;

        public ManagerDelegateRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }

        #endregion

        #region Save Delegations Details

        public async Task<string> AddOrUpdateDelegatesAsync(PostManagerDelegateDTO managerdelegate)
        {
            // Create a connection using the connection string
            using (var connection = new SqlConnection(_connectionString))
            {
                // Create a command object
                using (var cmd = new SqlCommand("dbo.AddOrUpdateDelegates", connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    #region SP Parameters
                    cmd.Parameters.AddWithValue("@ManagerID", managerdelegate.ManagerID);
                    cmd.Parameters.AddWithValue("@DelegateID", managerdelegate.DelegateID);
                    cmd.Parameters.AddWithValue("@StartDate", managerdelegate.StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", managerdelegate.EndDate);
                    cmd.Parameters.AddWithValue("@ModUser", managerdelegate.ModUser);
                    #endregion

                    // Open the connection
                    await connection.OpenAsync();

                    // Execute the stored procedure
                    await cmd.ExecuteNonQueryAsync();

                    return "Add/Update Successful";
                }
            }
        }

        #endregion

        #region Get Delegates Details

        public async Task<List<GetManagerDelegateDTO>> GetManagerDelegateInfoAsync()
        {
            var managerdelegates = new List<GetManagerDelegateDTO>();

            #region DB Connection and Fetching Data

            using (var connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetManagerDelegateMapping", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                await connection.OpenAsync();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    #region Fetching Data from DB

                    while (reader.Read())
                    {
                        managerdelegates.Add(new GetManagerDelegateDTO
                        {
                            ManagerID = reader.GetInt32(reader.GetOrdinal("ManagerID")),
                            DelegateID = reader.GetInt32(reader.GetOrdinal("DelegateID")),
                            StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                            EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                            ManagerName = reader.GetString(reader.GetOrdinal("ManagerName")),
                            DelegateName = reader.GetString(reader.GetOrdinal("DelegateName")),
                            ModifiedBy = reader.GetInt32(reader.GetOrdinal("ModifiedBy")),
                            ModifiedByName = reader.GetString(reader.GetOrdinal("ModifiedByName")),
                            ModifiedOn = reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                        });
                    }

                    #endregion
                }
            }

            #endregion
            return (managerdelegates);
        }

        #endregion

        #region Get All Managers List

        public async Task<List<GetAllManagersDTO>> GetAllManagersInfoAsync()
        {
            var managers = new List<GetAllManagersDTO>();

            #region DB Connection and Fetching Data

            using (var connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.GetAllManagers", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                await connection.OpenAsync();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    #region Fetching Data from DB

                    while (reader.Read())
                    {
                        managers.Add(new GetAllManagersDTO
                        {
                            UserID = reader.GetInt32(reader.GetOrdinal("ManagerID")),
                            UserName = reader.GetString(reader.GetOrdinal("ManagerName")),
                        });
                    }

                    #endregion
                }
            }

            #endregion


            return (managers);
        }

        #endregion
    }
}
