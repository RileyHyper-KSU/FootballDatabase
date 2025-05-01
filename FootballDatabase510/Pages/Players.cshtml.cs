using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace FootballDatabase510.Pages
{
    public class PlayersModel : PageModel
    {
        private readonly ILogger<PlayersModel> _logger;

        public PlayersModel(ILogger<PlayersModel> logger)
        {
            _logger = logger;
        }

        public void OnGet()
        {
        }
    }
}