using Microsoft.AspNetCore.Mvc;
using MessageMicroService.Services;
//using System.Text.Json;
using Newtonsoft.Json;
using MessageMicroService.Models;
using Microsoft.AspNetCore.SignalR.Protocol;
using System.Net;

namespace MessageMicroService.Controller
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessageController : ControllerBase
    {

        private readonly IConfiguration _config;
        private readonly ILogger<IMessageService> _logger;
        private readonly IMessageService _messageService;
        //private readonly IMessageCustomer _messageCustomer;


        public MessageController(ILogger<IMessageService> logger, IConfiguration config, IMessageService messageService)//, IMessageCustomer messageCustomer)
        {
            _logger = logger;
            _config = config;
            _messageService = messageService;
            //_messageCustomer = messageCustomer;
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
            Console.WriteLine(pattern);
            _messageService.GetFilteredMovieList(pattern);

            Task<string> movieMessage = ListenForResult();

            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessage);
        }


        [HttpGet("movie/{movieId}")]  // how about promise??????
        public async Task<List<Movie>> GetMovie(string movieId) //await not working unless async function
        {
            _messageService.GetMovieById(movieId);

            Task<string> movieMessage = ListenForResult();

            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessage);
        }

        [HttpGet("customers")] // how about promise??????
        public async Task<List<Customer>> GetCustomers() //await not working unless async function
        {
            Console.WriteLine("Endpoint reached");
            _messageService.GetAllCustomers();

            Task<string> customerMessage = ListenForResult();

            return JsonConvert.DeserializeObject<List<Customer>>(await customerMessage);

        }

        [HttpPost("watchlist")]
        public async Task<HttpStatusCode> AddMovieToWatchList([FromBody] WatchList watchlist ) //await not working unless async function
        {
            Console.WriteLine("Endpoint reached");
            _messageService.AddMovieToWatchList(watchlist);

            Task<string> customerMessage = ListenForResult();

            return HttpStatusCode.OK; 
        }
        /*async Task<string> ListenForCustomerResult() //await not working unless async function
        {
            _logger.LogInformation($"waiting for return messages.");
            System.Threading.Thread.Sleep(2000);

            return _messageCustomer.GetResults();
        }*/


        Task<string> ListenForResult() //await not working unless async function
        {
            _logger.LogInformation($"waiting for return messages.");
            System.Threading.Thread.Sleep(2000);

            return Task.FromResult(_messageService.GetResults());
        }

    }

}
