using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using RabbitMQ.Client.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System.Threading.Channels;
using CustomerMicroService.Models;
using System.Text.Json;
using Microsoft.AspNetCore.Connections;
using CustomerMicroService.Controllers;
using SharedModelLibrary;

namespace CustomerMicroService
{
    public class CustomerWorker : SharedModelLibrary.Worker
    {
        private CustomerController customerController;
        private readonly string listenQueueName = "customers";

        public CustomerWorker(CustomerController customerController, string listenQueueName) :
            base(customerController, listenQueueName)
        {
        }
    }
}

