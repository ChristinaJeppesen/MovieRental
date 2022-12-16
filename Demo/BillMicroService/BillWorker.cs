using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using BillMicroService.Controller;
using Microsoft.EntityFrameworkCore.Query;
using SharedModelLibrary;

namespace BillMicroService
{
    public class BillWorker : SharedModelLibrary.Worker
    {
        private readonly ILogger<BillWorker> _logger;
        private readonly BillController _billController;
        private const string listenQueueName = "bills";

        public BillWorker(BillController _billController, string listenQueueName) :
            base(_billController, listenQueueName)
        {
        }
    }
}




