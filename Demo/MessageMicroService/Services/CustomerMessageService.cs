using System;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MessageMicroService.Models;
using System.Text.Json;
using System.Text;
using System.Text.RegularExpressions;
using SharedModelLibrary;

namespace MessageMicroService.Services
{
    public partial class MessageService : IMessageService
    {

        private readonly string CustomerServicePublishQueueName = "results";
        private readonly string CustomerServiceListenQueueName = "customers";

        public void GetAllCustomers()
        {
            Message<string> message = new(1, CustomerServiceListenQueueName, CustomerServicePublishQueueName, "GetAllCustomers", null);
            message.PublishMessageRMQ();
        }

        public void AddMovieToWatchList(WatchList watchlist)
        {
            Message<WatchList> message = new(1, CustomerServiceListenQueueName, CustomerServicePublishQueueName, "AddMovieToWatchList", watchlist);
            message.PublishMessageRMQ();
            
        }

        public void GetCustomerWatchListById(Guid customerId)
        {

            Message<Guid> message = new(1, CustomerServiceListenQueueName, "movies", "GetCustomerWatchListById", customerId);
            message.PublishMessageRMQ();
            

        }
    }
}

