using System.Data;
using System.Text.RegularExpressions;
using UCITMS.Models;

namespace UCITMS.Data.IRepositories
{
    
    public interface IHelperRepository
    {
        #region Get Lookup Values
        List<GetLookupDTO> GetLookupValues(string lookupId);

        #endregion

        #region Get Audit trail by id, key, fieldname
        Task<List<AuditTrailDTO>> GetAuditTrail(int tableId, int tableKey, string fieldName);
        #endregion


        #region Generic Call to get data in Data table
        DataTable GetGenericData(GenericCommandDTO obj);

        #endregion

        #region StripHTML
        public string StripHTML(string input);

        #endregion

        public string DecodeStripAndTrimHTML(string input);

        #region Strip and Encode HTML
        string StripAndEncodeHTML(string input);
        #endregion
    }
}
