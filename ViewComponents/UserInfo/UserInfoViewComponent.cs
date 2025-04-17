using Microsoft.AspNetCore.Mvc;
using UCITMS.Models;

namespace UCITMS.ViewComponents.UserInfo
{
    public class UserInfoViewComponent : ViewComponent
    {
        public async Task<IViewComponentResult> InvokeAsync(UserDTO user)
        {
            if (user == null)
            {
                // Provide default values if the user is null
                user = new UserDTO
                {
                    Username = "Guest User",
                    Email = "guest@example.com"
                };
            }
            return View(user);

        }
    }
}
