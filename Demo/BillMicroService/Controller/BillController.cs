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

            Message<Bill>? message = JsonSerializer.Deserialize<Message<Bill>>(inMessage);
            dynamic response = null;

            if (message.FunctionToExecute == "GetCustomerBills")
            {
                response = _billService.GetCustomerBillList(_config);

            }
            else if (message.FunctionToExecute == "CreateBill")
            {
                response = _billService.CreateBill(_config, message.Arguments);
            }
            else if (message.FunctionToExecute == "UpdatePayment")
            {
                response =_billService.UpdatePayment(_config);

            }
            //string restlist = JsonSerializer.Serialize(response);

            return (message.PublishQueueName, JsonSerializer.Serialize(response));
        }
    }
}
