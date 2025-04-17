using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Data.Repositories
{
    public class UserRepository: IUserRepository
    {
        #region Variables and Constructors

        private string _connectionString;
        private IConfiguration _configuration;

        public UserRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }
        #endregion

        #region Get All Users
        public async Task<List<UserDTO>> GetAllUsers()
        {
            var userList = new List<UserDTO>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("GetUsers", conn)
                {
                    CommandType = System.Data.CommandType.StoredProcedure
                };

                await conn.OpenAsync();

                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var user = new UserDTO
                        {
                            UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                            Username = reader.GetString(reader.GetOrdinal("DisplayName")),
                            Email = reader.GetString(reader.GetOrdinal("Email"))
                        };
                        userList.Add(user);
                    }
                }
            }

            return userList;
        }
        #endregion

    }
}
