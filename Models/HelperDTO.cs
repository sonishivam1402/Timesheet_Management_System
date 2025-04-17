using UCITMS.Common;

namespace UCITMS.Models
{
    #region Get Lookup Values
    public class GetLookupDTO
    {
        public string CategoryName { get; set; }
        public string Key { get; set; }
        public int Value { get; set; }
    }

    #endregion

    #region Generic Command DTO
    public class GenericCommandDTO
    {
        public GenericCommandType CommandType { get; set; }
        public int CurrentUserId { get; set; }
        public string Parameter1 { get; set; }
        public string Parameter2 { get; set; }

        public string Parameter3 { get; set; }

        public string Parameter4 { get; set; }

        public string DataTableName { get; set; }

    }

    #endregion
}
