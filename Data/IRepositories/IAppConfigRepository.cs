using UCITMS.Common;
using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    public interface IAppConfigRepository
    {
        #region Get Config Value
        string GetValue(ConfigType ConfigType);
        #endregion

        #region Get Template Text
        string GetTemplate(TemplateType TemplateType);
        #endregion

        #region Get All Configurations
        List<GetConfigDTO> GetAllConfigurations();
        #endregion

        #region Update configuration
        Task<bool> UpdateConfiguration(PostConfigDTO config);
        #endregion
    }
}
