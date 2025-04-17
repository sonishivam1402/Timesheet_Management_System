using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using Microsoft.Data.SqlClient;
using UCITMS.Common;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using System.Text.RegularExpressions;
using System.Web;

namespace UCITMS.Data.Repositories
{
    public class HelperRepository : IHelperRepository
    {
        #region Dependency Injection

        private readonly string _connectionString;
        private IConfiguration _configuration;

        public HelperRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }

        #endregion

        #region Get Lookup Values

        public List<GetLookupDTO> GetLookupValues(string lookupId)
        {
            var lookupValues = new List<GetLookupDTO>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("GetLookupValues", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@LookupIds", SqlDbType.VarChar) { Value = lookupId });

                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            lookupValues.Add(new GetLookupDTO
                            {
                                CategoryName = reader["CategoryName"].ToString(),
                                Key = reader["Key"].ToString(),
                                Value = Convert.ToInt32(reader["Value"])
                            });
                        }
                    }
                }
            }

            return lookupValues;
        }
        #endregion

        #region Get Audit trail by id, key, fieldname
        public async Task<List<AuditTrailDTO>> GetAuditTrail(int tableId, int tableKey, string fieldName)
        {
            var auditTrails = new List<AuditTrailDTO>();

            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("GetAuditTrail", connection)) 
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@TableId", SqlDbType.Int) { Value = tableId });
                    command.Parameters.Add(new SqlParameter("@TableKey", SqlDbType.Int) { Value = tableKey });
                    command.Parameters.Add(new SqlParameter("@FieldName", SqlDbType.VarChar) { Value = fieldName });

                    connection.Open();
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var auditTrail = new AuditTrailDTO
                            {
                                LogId = reader.GetInt32(reader.GetOrdinal("LogId")),
                                TableId = reader.GetInt32(reader.GetOrdinal("TableId")),
                                TableName = reader.GetString(reader.GetOrdinal("TableName")),
                                TableKey = reader.GetInt32(reader.GetOrdinal("TableKey")),
                                FieldName = reader.GetString(reader.GetOrdinal("FieldName")),
                                PreviousValue = reader.IsDBNull(reader.GetOrdinal("PreviousValue")) ? null : reader.GetString(reader.GetOrdinal("PreviousValue")),
                                NewValue = reader.IsDBNull(reader.GetOrdinal("NewValue")) ? null : reader.GetString(reader.GetOrdinal("NewValue")),
                                ModifiedBy = reader.GetInt32(reader.GetOrdinal("ModifiedBy")),
                                ModifiedOn = reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                                BatchId = reader.GetString(reader.GetOrdinal("BatchId"))
                            };
                            auditTrails.Add(auditTrail);
                        }
                    }
                }
            }

            return auditTrails;
        }
        #endregion

        #region Generic Call to Get Data in DataTable
        public DataTable GetGenericData(GenericCommandDTO obj)
        {
            // Assign default values to avoid nulls
            obj.DataTableName ??= "Table1";
            obj.Parameter1 ??= "";
            obj.Parameter2 ??= "";
            obj.Parameter3 ??= "";
            obj.Parameter4 ??= "";

            // Using 'using' to ensure proper resource cleanup
            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = conn.CreateCommand())
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.GenericCommand"; // Removed redundant variable

                // Add parameters
                cmd.Parameters.Add(new SqlParameter("@CommandId", SqlDbType.Int) { Value = obj.CommandType });
                cmd.Parameters.Add(new SqlParameter("@CurrentUser", SqlDbType.Int) { Value = obj.CurrentUserId });
                cmd.Parameters.Add(new SqlParameter("@Param1", SqlDbType.VarChar) { Value = obj.Parameter1 });
                cmd.Parameters.Add(new SqlParameter("@Param2", SqlDbType.VarChar) { Value = obj.Parameter2 });
                cmd.Parameters.Add(new SqlParameter("@Param3", SqlDbType.VarChar) { Value = obj.Parameter3 });
                cmd.Parameters.Add(new SqlParameter("@Param4", SqlDbType.VarChar) { Value = obj.Parameter4 });

                // Use DataAdapter to fill DataSet
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataSet ds = new DataSet();
                    da.Fill(ds);

                    // Name the first table
                    if (ds.Tables.Count > 0)
                        ds.Tables[0].TableName = obj.DataTableName;

                    return ds.Tables[0];
                }
            }
        }
        #endregion

        #region StripHTML
        public string StripHTML(string input)
        {
            return Regex.Replace(input, "<.*?>", String.Empty);
        }
        #endregion

        #region
        public string DecodeStripAndTrimHTML(string input)
        {
            string decodedInput = HttpUtility.HtmlDecode(input);
            return StripHTML(decodedInput).Trim();
        }
        #endregion 

        #region Strip and Encode html
        public string StripAndEncodeHTML(string input)
        {
            return Regex.Replace(DecodeStripAndTrimHTML(input), "['\"]", match =>
            {
                if (match.Value == "'")
                {
                    return "&#39;";
                } else if (match.Value == "\"") {
                    return "&quot;";
                } else
                {
                    return match.Value;
                }
            });
        }
        #endregion
    }
}
