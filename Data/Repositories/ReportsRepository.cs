using Microsoft.Data.SqlClient;
using Microsoft.SqlServer.Server;
using System.Data;
using System.Drawing;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Data.Repositories
{
    public class ReportsRepository : IReportsRepository
    {
        private string _connectionString;
        private IConfiguration _configuration;

        public ReportsRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }

        public async Task<List<ReportsDTO>> GetManagerReportAsync(int ManagerId)
        {
            var result = new List<ReportsDTO>();

            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand(@$"SELECT Employee as 'Employee Name',SecondaryManagerName As 'Secondary Manager', SubmittedOn as 'Submitted On', ApprovedOn as 'Approved On', ApprovedByName as 'Approved By', StartDate as 'Start Date', EndDate as 'End Date',  StatusName as 'Status Name', Duration, EngagementName as 'Engagement Name', TaskName as 'Task Name', EntryDate as 'Entry Date', TotalHours as 'Total Hours', Comments
   FROM dbo.udfTimesheetSumamry() where (ManagerID = {ManagerId} OR ISNULL(SecondaryManagerId, 0) = @SecondaryManagerId) AND StatusName IN ('Approved', 'Submitted')", connection))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.AddWithValue("@ManagerId", ManagerId);
                    command.Parameters.AddWithValue("@SecondaryManagerId", ManagerId);
                    connection.Open();

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            result.Add(new ReportsDTO
                            {
                               
                                Employee = reader.IsDBNull(reader.GetOrdinal("Employee Name")) ? string.Empty : reader.GetString(reader.GetOrdinal("Employee Name")),
                               // ManagerId = reader.IsDBNull(reader.GetOrdinal("ManagerId")) ? 0 : reader.GetInt32(reader.GetOrdinal("ManagerId")),

                                SecondaryManagerName = reader.IsDBNull(reader.GetOrdinal("Secondary Manager")) ? string.Empty : reader.GetString(reader.GetOrdinal("Secondary Manager")),
                                SubmittedOn = reader.IsDBNull(reader.GetOrdinal("Submitted On")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("Submitted On")),
                                ApprovedOn = reader.IsDBNull(reader.GetOrdinal("Approved On")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("Approved On")),
                               
                                ApprovedByName = reader.IsDBNull(reader.GetOrdinal("Approved By")) ? string.Empty : reader.GetString(reader.GetOrdinal("Approved By")),
                                
                                StartDate = reader.IsDBNull(reader.GetOrdinal("Start Date")) ? (DateTime?)null : (reader.GetDateTime(reader.GetOrdinal("Start Date"))),
                                EndDate = reader.IsDBNull(reader.GetOrdinal("End Date")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("End Date")),
                                
                                StatusName = reader.IsDBNull(reader.GetOrdinal("Status Name")) ? string.Empty : reader.GetString(reader.GetOrdinal("Status Name")),
                                Duration = reader.IsDBNull(reader.GetOrdinal("Duration")) ? string.Empty : reader.GetString(reader.GetOrdinal("Duration")),
                               
                                EngagementName = reader.IsDBNull(reader.GetOrdinal("Engagement Name")) ? string.Empty : reader.GetString(reader.GetOrdinal("Engagement Name")),
                                
                                TaskName = reader.IsDBNull(reader.GetOrdinal("Task Name")) ? string.Empty : reader.GetString(reader.GetOrdinal("Task Name")),
                                EntryDate = reader.IsDBNull(reader.GetOrdinal("Entry Date")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("Entry Date")),
                                
                                TotalHours = reader.IsDBNull(reader.GetOrdinal("Total Hours")) ? 0 : reader.GetDouble(reader.GetOrdinal("Total Hours")),
                                Comments = reader.IsDBNull(reader.GetOrdinal("Comments")) ? string.Empty : reader.GetString(reader.GetOrdinal("Comments"))
                            });
                        }
                    }
                }
            }

            return result;

        }

        public async Task<List<ReportsSchemaDTO>> GetReportsSchemaAsync(int ID)
        {
            List<ReportsSchemaDTO> result =  new List<ReportsSchemaDTO>();

            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("[DBO].[GetReportsSchema]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@CURRENTUSERID", ID);

                    await connection.OpenAsync();
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var obj = new ReportsSchemaDTO
                            {
                                ID = reader.GetInt32("ID"),
                                ViewName = reader.GetString("ViewName"),
                                Slice = reader.GetString("Slice"),
                                Formats = reader.GetString("Formats"),
                                forSU = reader.GetBoolean("forSU")
                            };

                            result.Add(obj);
                        }
                    }
                }
            }


                return result;
        }


    }
}
