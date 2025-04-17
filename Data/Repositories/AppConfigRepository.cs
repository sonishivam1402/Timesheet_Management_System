using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace UCITMS.Data.Repositories
{
    public class AppConfigRepository : IAppConfigRepository
    {
        #region Variables and Constructors

        private string _connectionString;
        private IConfiguration _configuration;

        public AppConfigRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }
        #endregion

        #region Get Config Value
        public string GetValue(ConfigType ConfigType)
        {
            string val = "";
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("[dbo].[GetConfigValue]", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ConfigId",(int) ConfigType);
                conn.Open();
                val = cmd.ExecuteScalar().ToString();
               
            }

            return val;
        }
        #endregion

        #region Get Template Text
        public string GetTemplate(TemplateType TemplateType)
        {
            string val = "";
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("[dbo].[GetTemplate]", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TemplateId", (int)TemplateType);
                conn.Open();
                val = cmd.ExecuteScalar().ToString();

            }

            return val;
        }
        #endregion

        #region Get All Configurations
        public List<GetConfigDTO> GetAllConfigurations()
        {
            List<GetConfigDTO> configurations = new List<GetConfigDTO>();
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("GetConfigurations", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    configurations.Add(new GetConfigDTO
                    {
                        Id = reader.GetInt32(reader.GetOrdinal("ID")),
                        Name = reader.IsDBNull(reader.GetOrdinal("Name")) ? null : reader.GetString(reader.GetOrdinal("Name")),
                        Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                        Value = reader.IsDBNull(reader.GetOrdinal("Value")) ? null : reader.GetString(reader.GetOrdinal("Value")),
                        ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                        ModifiedBy = reader.GetInt32(reader.GetOrdinal("ModifiedBy")),
                        ModifiedByName = reader.GetString(reader.GetOrdinal("ModifiedByName")),
                    });
                }
            }

            return configurations;
        }
        #endregion

        #region Update Configuration
        public async Task<bool> UpdateConfiguration(PostConfigDTO config)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("UpdateConfiguration", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ID", config.Id);
                cmd.Parameters.AddWithValue("@Value", config.Value);
                cmd.Parameters.AddWithValue("@ModifiedBy", config.ModifiedBy);

                conn.Open();
                int rowsAffected = cmd.ExecuteNonQuery();

                return rowsAffected > 0;
            }
        }
        #endregion
    }
}