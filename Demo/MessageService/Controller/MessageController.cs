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
        private readonly IMessageCustomer _messageCustomer;


        public MessageController(ILogger<Worker> logger, IConfiguration config, IMessageService messageService, IMessageCustomer messageCustomer)
        {
            _logger = logger;
            _config = config;
            _messageService = messageService;
            _messageCustomer = messageCustomer;
        }

        [HttpGet("movies")] // how about promise??????
        public async Task<List<Movie>> GetAllMovies() //await not working unless async function
        {
            _messageService.GetAllMovieList();

            Task<string> movieMessage = ListenForResult();
                
            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessage);

        }

        [HttpGet("movies/{filter}/{match}")]  // how about promise??????
        public async Task<List<Movie>> GetFilteredMovies(string filter, string match) //await not working unless async function
        {   
            _messageService.GetFilteredMovieList(filter, match);

            Task<string> movieMessage = ListenForResult();

            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessage);

        }


        [HttpGet("customers")] // how about promise??????
        public async Task<List<Customer>> GetCustomers() //await not working unless async function
        {
            Console.WriteLine("Endpoint reached");
            _messageCustomer.GetAllCustomers();

            Task<string> customerMessage = ListenForCustomerResult();

            return JsonConvert.DeserializeObject<List<Customer>>(await customerMessage);

        }

        async Task<string> ListenForCustomerResult() //await not working unless async function
        {
            _logger.LogInformation($"waiting for return messages.");
            System.Threading.Thread.Sleep(2000);

            return _messageCustomer.GetResults();
        }


        async Task<string> ListenForResult() //await not working unless async function
        {
            _logger.LogInformation($"waiting for return messages.");
            System.Threading.Thread.Sleep(2000);

            return _messageService.GetResults();
        }

    }

}
