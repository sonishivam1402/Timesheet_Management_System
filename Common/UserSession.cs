using Microsoft.AspNetCore.Http;

namespace UCITMS
{

    public static class UserSession
    {
        private const string UserIdSessionKey = "UserId";
        private const string UserNameSessionKey = "UserName";
        private const string UserEmailSessionKey = "UserEmail";
        private const string RoleIdSessionKey = "RoleId";
        private const string EnvVarSessionKey = "EnvVar";

        // Method to store user ID in session
        public static void StoreUserId(HttpContext context, int userId)
        {
            context.Session.SetString(UserIdSessionKey, userId.ToString()); 
        }

        // Method to get user ID from session
        public static int? GetUserId(HttpContext context)
        {
            var userIdString = context.Session.GetString(UserIdSessionKey);
            if (int.TryParse(userIdString, out var userId))
            {
                return userId; // Return as integer
            }
            return null; // Return null if not found
        }

        // Method to store Username in session
        public static void StoreUserName(HttpContext context, string username)
        {
            context.Session.SetString(UserNameSessionKey, username);
        }

        // Method to get Username from session
        public static string GetUserName(HttpContext context)
        {
            string userNameString = context.Session.GetString(UserNameSessionKey);
            if (userNameString != null)
            {
                return userNameString; // Return Name String
            }
            return null; // Return null if not found
        }

        //Method to store UserEmail in session
        public static void StoreUserEmail(HttpContext context, string useremail)
        {
            context.Session.SetString(UserEmailSessionKey, useremail);
        }

        // Method to get UserEmail from session
        public static string GetUserEmail(HttpContext context)
        {
            string userEmailString = context.Session.GetString(UserEmailSessionKey);
            if (userEmailString != null)
            {
                return userEmailString; // Return Email String
            }
            return null; // Return null if not found
        }

        // Method to store role ID in session
        public static void StoreRoleId(HttpContext context, int roleId)
        {
            context.Session.SetString(RoleIdSessionKey, roleId.ToString());
        }

        // Method to get role ID from session
        public static int? GetRoleId(HttpContext context)
        {
            var roleIdString = context.Session.GetString(RoleIdSessionKey);
            if (int.TryParse(roleIdString, out var roleId))
            {
                return roleId; // Return as integer
            }
            return null; // Return null if not found
        }

        // Method to store EnvVar in session
        public static void StoreEnvVar(HttpContext context, string envvar)
        {
            context.Session.SetString(EnvVarSessionKey, envvar);
        }

        // Method to get EnvVar from session
        public static string GetEnvVar(HttpContext context)
        {
            string envVarString = context.Session.GetString(EnvVarSessionKey);
            if (envVarString != null)
            {
                return envVarString; // Return Name String
            }
            return null; // Return null if not found
        }
    }

}
