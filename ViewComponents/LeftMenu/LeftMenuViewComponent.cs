using Microsoft.AspNetCore.Mvc;
using UCITMS.Data.IRepositories;
using UCITMS.ViewModels;

namespace UCITMS.ViewComponents.LeftMenu
{
    public class LeftMenuViewComponent: ViewComponent
    {
        private readonly IMenuRepository _menuRepository;

        public LeftMenuViewComponent(IMenuRepository menuService)
        {
            _menuRepository = menuService;
        }

        public async Task<IViewComponentResult> InvokeAsync(string selectedMenuPath)
        {
            int userId = (int)UserSession.GetUserId(HttpContext);
            List<VMMenu> items = await _menuRepository.GetUserMenuById(userId);
            ViewData["SelectedMenuPath"] = selectedMenuPath;
            return View(items);
        }
    }
}
