using Microsoft.AspNetCore.Mvc;
using MessageService.Service;
//using System.Text.Json;
using Newtonsoft.Json;
using MessageService.Models;
using Microsoft.AspNetCore.SignalR.Protocol;

namespace MessageService.Controller
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessageController : ControllerBase
    {

        private readonly IConfiguration _config;
        private readonly ILogger<Worker> _logger;
        private readonly IMessageService _messageService;

        public MessageController(ILogger<Worker> logger, IConfiguration config, IMessageService messageService)
        {
            _logger = logger;
            _config = config;
            _messageService = messageService;
        }

        [HttpGet("movies")] // how about promise??????
        public async Task<List<Movie>> GetAllMovies() //await not working unless async function
        {
            _messageService.GetAllMovieList();

            Task<string> movieMessage = ListenForResult();
                
            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessage);

        }
        [HttpGet("movies/{pattern}")]  // how about promise??????
        public async Task<List<Movie>> GetFilteredMovies(string pattern) //await not working unless async function
        {   
            _messageService.GetFilteredMovieList(pattern);

            Task<string> movieMessage = ListenForResult();

            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessage);

        }

        Task<string> ListenForResult() //await not working unless async function
        {
            _logger.LogInformation($"waiting for return messages.");
            System.Threading.Thread.Sleep(2000);

            return Task.FromResult(_messageService.GetResults());
        }

    }

}
