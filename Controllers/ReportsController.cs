using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Data;
using System.Text;
using UCITMS.Common;
using UCITMS.Data.IRepositories;
using UCITMS.Data.Repositories;
using UCITMS.Models;

namespace UCITMS.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReportsController : Controller
    {
        private readonly IReportsRepository _repository;
        private readonly IHelperRepository _helperRepository;
        public ReportsController(IReportsRepository repository, IHelperRepository helperRepository)
        {
            _repository = repository;
            _helperRepository = helperRepository;
        }

        [AppAuthorizationFilter(AutherizationType.Menu, Item.Reports)]
        [HttpGet("getview")]
        public async Task<IActionResult> GetView()
        {
            int ID = (int)UserSession.GetUserId(HttpContext);
            List<ReportsSchemaDTO> obj = await _repository.GetReportsSchemaAsync(ID);
            return Ok(obj);
        }


        [AppAuthorizationFilter(AutherizationType.Menu, Item.Reports)]
        [HttpGet("timesheetsummary/{selectedViewId}")]
        public IActionResult GetManagerReport(int selectedViewId)
        {
            // Fetching the data using the existing logic
            GenericCommandDTO obj = new GenericCommandDTO
            {
                CurrentUserId = (int)UserSession.GetUserId(HttpContext),
                CommandType = GenericCommandType.TimesheetSummaryReport,
                Parameter1 = selectedViewId.ToString()
            };

            DataTable tbl = _helperRepository.GetGenericData(obj);

            if (tbl == null || tbl.Rows.Count == 0)
            {
                return NotFound("No records found");
            }

            // Convert DataTable to CSV format
            var csvContent = ConvertDataTableToCsv(tbl);

            // Return the CSV content as a file response
            return File(
                System.Text.Encoding.UTF8.GetBytes(csvContent),
                "text/csv",
                "ManagerReport.csv"
            );
        }

        // Helper method to convert DataTable to CSV
        private string ConvertDataTableToCsv(DataTable table)
        {
            var csvBuilder = new StringBuilder();

            // Adding column headers
            var columnNames = table.Columns.Cast<DataColumn>().Select(column => column.ColumnName);
            csvBuilder.AppendLine(string.Join(",", columnNames));

            // Adding rows
            foreach (DataRow row in table.Rows)
            {
                var fields = row.ItemArray.Select(field => field.ToString().Replace(",", "\\,"));
                csvBuilder.AppendLine(string.Join(",", fields));
            }

            return csvBuilder.ToString();
        }

    }
}
