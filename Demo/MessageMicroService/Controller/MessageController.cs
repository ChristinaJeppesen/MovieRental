using Microsoft.AspNetCore.Mvc;
using MessageMicroService.Services;
//using System.Text.Json;
using Newtonsoft.Json;
using MessageMicroService.Models;
using Microsoft.AspNetCore.SignalR.Protocol;
using System.Net;
using System.Runtime.InteropServices;
using SharedModelLibrary;

namespace MessageMicroService.Controller
{
    [Route("api/")] 
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

            Task<string> movieMessageResponse = ListenForResult();

            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessageResponse);

        }
        [HttpGet("movies/browse/{pattern}")]  // how about promise??????
        public async Task<List<Movie>> GetFilteredMovies(string pattern) //await not working unless async function
        {
            Console.WriteLine(pattern);
            _messageService.GetFilteredMovieList(pattern);

            Task<string> movieMessageResponse = ListenForResult();

            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessageResponse);
        }


        [HttpGet("movies/{movieId}")]  // how about promise??????
        public async Task<List<Movie>> GetMovie(int movieId) //await not working unless async function
        {
            _messageService.GetMovieById(movieId);

            Task<string> movieMessageResponse = ListenForResult();

            return JsonConvert.DeserializeObject<List<Movie>>(await movieMessageResponse);
        }


        [HttpPut("customer/info/")] // how about promise??????
        public async Task<int> UpdateCustomerInformation([FromBody] Customer customer) //await not working unless async function
        {
            Console.WriteLine("Endpoint reached");
            _messageService.UpdateCustomerInformation(customer);

            Task<string> customerMessageResponse = ListenForResult();

            return JsonConvert.DeserializeObject<int>(await customerMessageResponse);

        }

        [HttpGet("customers")] // how about promise??????
        public async Task<List<Customer>> GetCustomers() //await not working unless async function
        {
            Console.WriteLine("Endpoint reached");
            _messageService.GetAllCustomers();

            Task<string> customerMessageResponse = ListenForResult();

            return JsonConvert.DeserializeObject<List<Customer>>(await customerMessageResponse);

        }

        [HttpGet("customer/{customerId}/historylist")]
        public async Task<List<HistoryItem>> GetCustomerHistoryList(Guid customerId)
        {
            _messageService.GetCustomerHistoryList(customerId);

            Task<string> customerMessageResponse = ListenForResult();

            return JsonConvert.DeserializeObject<List<HistoryItem>>(await customerMessageResponse);

        }

        [HttpGet("{customerId}/watchlist")]
        public async Task<List<string>> GetCustomerWatchList(Guid customerId)
        {
            _messageService.GetCustomerWatchListById(customerId);

            Task<string> customerMessageResponse = ListenForResult();

            return JsonConvert.DeserializeObject<List<string>>(await customerMessageResponse);

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






        // bills 
        [HttpGet("{customerId}/bills")] // how about promise??????
        public async Task<List<Bill>> GetCustomerBills(Guid customerId) //await not working unless async function
        {
            _messageService.GetCustomerBills(customerId);

            Task<string> billMessage = ListenForResult();

            return JsonConvert.DeserializeObject<List<Bill>>(await billMessage);

        }
        
        [HttpPost("{customerId}/bills")]  // how about promise??????
        public async Task<string> CreateCustomerBill(Guid customerId, Bill bill) //await not working unless async function
        {
            _logger.LogInformation(bill.Price.ToString());

            bill.CustomerId = customerId;
            _messageService.CreateCustomerBill(bill);

            Task<string> billMessageResponse = ListenForResult();

            return JsonConvert.DeserializeObject<string>(await billMessageResponse);
        }
        [HttpPut("{customerId}/bills")] // how about promise??????
        public async Task<string> UpdateCustomerBill(Guid customerId, Bill bill) //await not working unless async function
        {
            bill.CustomerId = customerId;
            _messageService.UpdateCustomerBill(bill);

            Task<string> billMessage = ListenForResult();

            return JsonConvert.DeserializeObject<string>(await billMessage);
        }


        Task<string> ListenForResult() //await not working unless async function
        {
            _logger.LogInformation($"waiting for return messages.");
            //System.Threading.Thread.Sleep(2000);

            return Task.FromResult(_messageService.GetResults());
        }

    }

}
