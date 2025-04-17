using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Models;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace UCITMS.Data.Repositories
{
    public class AuthorizationRepository : IAuthorizationRepository
    {
        #region Variables and Constructors

        private string _connectionString;
        private IConfiguration _configuration;

        public AuthorizationRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }
        #endregion

        #region Check if User is Authorized
        public bool isAuthorized(int autherizationTypeId, int Itemid, int CurrentUserId)
        {
            bool _hasAccess = false;
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("[dbo].[isAuthorized]", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@autherizationTypeId", autherizationTypeId);
                cmd.Parameters.AddWithValue("@Itemid", Itemid);
                cmd.Parameters.AddWithValue("@CurrentUserId", CurrentUserId);
                conn.Open();
                _hasAccess=bool.Parse(cmd.ExecuteScalar().ToString());
               
            }

            return _hasAccess;
        }
        #endregion

        #region Check current User Access on Timesheet Actions
        public bool TimesheetAccess(AutherizationType autherizationTypeId, int TimeSheetId, int CurrentUserId)
        {
            
            return isAuthorized((int)autherizationTypeId, TimeSheetId,CurrentUserId);
        }
        #endregion



    }
}
