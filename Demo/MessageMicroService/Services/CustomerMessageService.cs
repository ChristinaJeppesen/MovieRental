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
            Message<string> message = new(CustomerServiceListenQueueName, CustomerServicePublishQueueName, "GetAllCustomers", null);
            message.PublishMessageRMQ();
        }

        public void UpdateCustomerInformation(Customer customer)
        {
            Message<Customer> message = new(CustomerServiceListenQueueName, CustomerServicePublishQueueName, "UpdateCustomerInformation", customer);
            message.PublishMessageRMQ();
        }

        public void AddMovieToWatchList(WatchList watchlist)
        {
            Message<WatchList> message = new(CustomerServiceListenQueueName, CustomerServicePublishQueueName, "AddMovieToWatchList", watchlist);
            message.PublishMessageRMQ();
            
        }

        public void GetCustomerWatchListById(Guid customerId)
        {
            Message<Guid> message = new(CustomerServiceListenQueueName, "movies", "GetCustomerWatchListById", customerId);
            message.PublishMessageRMQ();
            
        }

        public void GetCustomerHistoryList(Guid customerId)
        {
            Message<Guid> message = new(CustomerServiceListenQueueName, "movies", "GetCustomerHistoryList", customerId);
            message.PublishMessageRMQ();
        }
    }
}

