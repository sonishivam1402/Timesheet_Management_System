using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using UCITMS.Data.IRepositories;

namespace UCITMS.Common
{
    public class AppAuthorizationFilter:Attribute, IAsyncAuthorizationFilter
    {
        private readonly int _authTypeId;
        private readonly int _ItemId;
       
        public AppAuthorizationFilter(AutherizationType authType, Item item)
        {
            _authTypeId = (int)authType;
            _ItemId = (int)item;
        }

        public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
        {
            int CurrentUser = (int)UserSession.GetUserId(context.HttpContext);
            IAuthorizationRepository _repo = context.HttpContext.RequestServices.GetRequiredService<IAuthorizationRepository>();

            bool _hasAccess = _repo.isAuthorized(_authTypeId, _ItemId, CurrentUser);
            if (!_hasAccess)
            {
                context.Result = new ForbidResult();
            }
        }
    }
}
