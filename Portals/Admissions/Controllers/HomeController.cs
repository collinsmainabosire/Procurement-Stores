using Microsoft.AspNetCore.Mvc;

namespace Admissions.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
