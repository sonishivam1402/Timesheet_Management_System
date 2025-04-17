using Microsoft.Data.SqlClient;
using System.Data;
using UCITMS.Data.IRepositories;
using UCITMS.ViewModels;

namespace UCITMS.Data.Repositories
{
    public class MenuRepository: IMenuRepository
    {
        #region Variables and Constructors

        private string _connectionString;
        private IConfiguration _configuration;


        public MenuRepository(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("connectionString");
        }
        #endregion

        #region Get User Menu by ID
        public async Task<List<VMMenu>> GetUserMenuById(int userId)
        {
            var menuList = new List<VMMenu>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("GetUserMenuById", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", userId);

                await conn.OpenAsync();

                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var menu = new VMMenu
                        {
                            ID = reader.GetInt32(reader.GetOrdinal("ID")),
                            MenuName = reader.GetString(reader.GetOrdinal("MenuName")),
                            ImagePath = reader.GetString(reader.GetOrdinal("ImagePath")),
                            NavigationPath = reader.GetString(reader.GetOrdinal("NavigationPath")),
                            NavigationType = reader.GetString(reader.GetOrdinal("NavigationType")),
                            SortOrder = reader.GetInt32(reader.GetOrdinal("SortOrder")),
                            IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                            IsDefault = reader.GetBoolean(reader.GetOrdinal("IsDefault")),
                            CreatedBy = reader.GetInt32(reader.GetOrdinal("CreatedBy")),
                            ModifiedBy = reader.GetInt32(reader.GetOrdinal("ModifiedBy"))
                        };
                        menuList.Add(menu);
                    }
                }
            }

            return menuList;
        }
        #endregion

        #region Get Default Menu for User
        public async Task<int> GetDefaultMenuIdByUserId(int userId)
        {
            List<VMMenu> menuList = await GetUserMenuById(userId);

            int defaultMenuId = menuList
                .Where(menu => menu.IsDefault)  
                .OrderBy(menu => menu.ID)       
                .Select(menu => menu.ID)        
                .FirstOrDefault();              

            return defaultMenuId;
        }
        #endregion
    }
}
