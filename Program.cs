using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;
using UCITMS.Data;
using UCITMS.Data.IRepositories;
using UCITMS.Data.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddSwaggerGen();
builder.Services.AddSession(options =>
{
    options.Cookie.Name = ".MySampleMVCWeb.Session"; // Name of the session cookie
    options.Cookie.HttpOnly = true; // Cookie is not accessible via JavaScript
    options.Cookie.IsEssential = true; // Essential cookie for the application
    options.Cookie.Path = "/"; // Cookie is valid for the entire site
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always; // Always use secure cookies
});


#region Inject Services

// Register repositories

builder.Services.AddScoped<IEngagementRepository, EngagementRepository>();

builder.Services.AddScoped<IMenuRepository,MenuRepository>();

builder.Services.AddScoped<ITimesheetRepository, TimesheetRepository>();

builder.Services.AddScoped<IHRAdminRepository, HRAdminRepository>();

builder.Services.AddScoped<ITaskRepository, TaskRepository>();
builder.Services.AddScoped<IDashboardRepository, DashboardRepository>();

builder.Services.AddScoped<IUserInfoRepository, UserInfoRepository>();

builder.Services.AddScoped<IUserRepository, UserRepository>();

builder.Services.AddScoped<IAuthorizationRepository, AuthorizationRepository>();
builder.Services.AddScoped<INotificationRepository, NotificationRepository>();
builder.Services.AddScoped<IAppConfigRepository, AppConfigRepository>();
builder.Services.AddScoped<IAdminRepository, AdminRepository>();
builder.Services.AddScoped<IManagerDelegateRepository, ManagerDelegateRepository>();
builder.Services.AddScoped<IHelperRepository, HelperRepository>();
builder.Services.AddScoped<IReportsRepository, ReportsRepository>();
builder.Services.AddScoped<ISuperUserRepository, SuperUserRepository>();

#endregion

builder.Services.AddHttpContextAccessor();
var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
//var isDevelopment = environment == Environments.Development;
var isDevelopment = true;


if (!isDevelopment)
{
    #region Add Authentication Service Configrations

    builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
   .AddMicrosoftIdentityWebApp(builder.Configuration, "EntraId");

    builder.Services.AddRazorPages().AddMvcOptions(options =>
    {
        var policy = new AuthorizationPolicyBuilder()
                      .RequireAuthenticatedUser()
                      .Build();
        options.Filters.Add(new AuthorizeFilter(policy));
    }).AddMicrosoftIdentityUI();
  
    #endregion
}
var app = builder.Build();

// Configure the HTTP request pipeline and middleware code to redirect back to the home page
if (!isDevelopment)
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
    app.Use(async (context, next) =>
    {
        if (context.Request.Path.StartsWithSegments("/Routing/Login"))
        {
            context.Response.Redirect("/");
        }
        else
        {
            await next();
        }
    });
}

app.UseSession();
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();
app.UseAuthentication();
//app.MapRazorPages();

app.MapControllers();

// Redirect from root URL to the login page
//app.MapGet("/", () => Results.Redirect("/Routing/Login"));

// Define the main route for your controllers

if (!isDevelopment)
{

    app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Routing}/{action=LandingPage}");
}
else
{
    app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Routing}/{action=Login}");

}

if (isDevelopment)
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Your API v1");
        c.RoutePrefix = "swagger"; // Swagger UI at /swagger
    });
}

app.Run();
