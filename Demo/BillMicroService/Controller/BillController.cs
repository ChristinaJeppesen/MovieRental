using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using BillMicroService.Services;
using BillMicroService.Models; 
using SharedModelLibrary;

namespace BillMicroService.Controller
{

    public class BillController : SharedModelLibrary.Controller
    {
        private readonly ILogger<BillController> _logger;
        private readonly IBillService _billService;
        private readonly IConfiguration _config;

        public BillController(ILogger<BillController> logger, IBillService billService, IConfiguration config)
        {
            _logger = logger;
            _billService = billService;
            _config = config;
        }

        public override (string, string) MessageReceived(string inMessage)
        {
            Console.WriteLine(" - Message Recieved");

            dynamic response = null;

            Message<dynamic>? message = JsonSerializer.Deserialize<Message<dynamic>>(inMessage);

            if (message.FunctionToExecute == "GetCustomerBills")
            {
                Guid customerId = JsonSerializer.Deserialize<Guid>(message.Arguments);
                response = _billService.GetCustomerBillList(_config, customerId);

            }
            else if (message.FunctionToExecute == "CreateCustomerBill")
            {
                Bill bill = JsonSerializer.Deserialize<Bill>(message.Arguments);
                int result = _billService.CreateBill(_config, bill);
                CustomerMovieList block = new CustomerMovieList(bill.CustomerId, bill.MovieIdList);
                response = new Message<CustomerMovieList>("customers", "results", "CreateHistoryListItems", block);

            }
            else if (message.FunctionToExecute == "UpdateCustomerBill")
            {
                Bill bill = JsonSerializer.Deserialize<Bill>(message.Arguments);
                response =_billService.UpdateCustomerBill(_config, bill);

            }

            return (message.PublishQueueName, JsonSerializer.Serialize(response));
        }
    }
}
