using Microsoft.Data.SqlClient;
using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Data.Repositories
{
    public class UserInfoRepository : IUserInfoRepository
    {
        #region Variables and Constructors
        private string _connectionString;
        private IConfiguration _configuration;

        public UserInfoRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }
        #endregion

        #region Get User by Email
        public UserDTO GetuserbyEmail(string Email)
        {
            UserDTO model = null;
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                string query = "GetUserInfo";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Email", Email);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    model = new UserDTO
                    {
                        UserID = Convert.ToInt32(reader["UserID"]),
                        Username = reader["DisplayName"].ToString(),
                        Email = reader["Email"].ToString(),
                        IsActive = Convert.ToBoolean(reader["isActive"]),
                        EnvVar = reader["Value"].ToString()
                    };
                }

            }

            return model;
        }
        #endregion
    }
}
