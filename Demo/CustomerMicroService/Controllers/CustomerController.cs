using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CustomerMicroService.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using CustomerMicroService.Services;
using Npgsql;
using System.Text.Json;
using SharedModelLibrary;
using RabbitMQ.Client.Events;
using System.Text;
using Microsoft.AspNetCore.SignalR.Protocol;

namespace CustomerMicroService.Controllers
{
    public class CustomerController : SharedModelLibrary.Controller
    {
        private readonly IConfiguration _config;
        private readonly ILogger<CustomerController> _logger;
        private readonly ICustomerMessage _customerMessage;


        public CustomerController(ILogger<CustomerController> logger, ICustomerMessage customerMessage,
            IConfiguration config)
        {
            _logger = logger;
            _customerMessage = customerMessage;
            _config = config;
            
        }

        public override (string, string) MessageReceived(string inMessage)
        {
            Console.WriteLine(" - Message Recieved");
            dynamic response = null;

            Message<dynamic>? customerMessage = JsonSerializer.Deserialize<Message<dynamic>>(inMessage);

            if (customerMessage.FunctionToExecute == "GetAllCustomers")
            {
                response = _customerMessage.GetAllCustomers(_config);
            }

            else if (customerMessage.FunctionToExecute == "GetCustomer")
            {
                response.Add(_customerMessage.GetCustomer(_config));
            }
            else if (customerMessage.FunctionToExecute == "AddMovieToWatchList")
            {

                WatchList w = JsonSerializer.Deserialize<WatchList>(customerMessage.Arguments);
                
                response = _customerMessage.AddMovieToWatchList(_config, w);

            }
            else if (customerMessage.FunctionToExecute == "GetCustomerWatchListById")
            {
                Guid customerId = JsonSerializer.Deserialize<Guid>(customerMessage.Arguments);
                
                var movieIdList = _customerMessage.GetCustomerWatchListById(_config, customerId);
                response = new Message<List<int>>("movies", "results", "GetMovieTitles", movieIdList);

            }
            else if (customerMessage.FunctionToExecute == "GetCustomerHistoryList")
            {
                Guid customerId = JsonSerializer.Deserialize<Guid>(customerMessage.Arguments);

                var movieIdList = _customerMessage.GetCustomerHistoryList(_config, customerId);
                response = new Message<List<HistoryItem>>("movies", "results", "ConstructHistoryList", movieIdList);

            }
            else if (customerMessage.FunctionToExecute == "UpdateCustomerInformation")
            {
                Customer customer = JsonSerializer.Deserialize<Customer>(customerMessage.Arguments);

                response = _customerMessage.UpdateCustomerInformation(_config, customer);
            }
            else if (customerMessage.FunctionToExecute == "CreateHistoryListItems")
            {
                CustomerMovieList billResultItems = JsonSerializer.Deserialize<CustomerMovieList>(customerMessage.Arguments);
                
                response = _customerMessage.AddHistoryListItems(_config, billResultItems);
            }

            return (customerMessage.PublishQueueName, JsonSerializer.Serialize(response));

        }
        

    }
}
