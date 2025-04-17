using Microsoft.AspNetCore.Mvc;
using UCITMS.Data.IRepositories;
using UCITMS.Models;

namespace UCITMS.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HelperController : ControllerBase
    {
        #region Dependency Injection
        private readonly IHelperRepository _helperRepository;

        public HelperController(IHelperRepository helperRepository)
        {
            _helperRepository = helperRepository;
        }

        #endregion

        #region Get Lookup Values
        [HttpGet("GetLookupValues/{lookupId}")]
        public IActionResult GetLookupValues(string lookupId)
        {
            List<GetLookupDTO> lookupValues = _helperRepository.GetLookupValues(lookupId);

            if (lookupValues != null && lookupValues.Any())
            {
                return Ok(lookupValues); 
            }
            else
            {
                return NotFound("No lookup values found."); 
            }
        }
        #endregion

        #region Get audit trail by table id, key, fieldname
        [HttpGet("{tableId}/{tableKey}/{fieldname}")]
        public async Task<IActionResult> GetAuditTrail(int tableId, int tableKey, string fieldname)
        {
            List<AuditTrailDTO> auditTrail = await _helperRepository.GetAuditTrail(tableId, tableKey, fieldname);
            return Ok(auditTrail);
        }
        #endregion
    }
}
