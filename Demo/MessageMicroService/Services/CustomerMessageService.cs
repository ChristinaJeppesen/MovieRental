using System;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MessageMicroService.Models;
using System.Text.Json;
using System.Text;
using System.Text.RegularExpressions;

namespace MessageMicroService.Services
{
    public partial class MessageService : IMessageService
    {

        private readonly string CustomerServicePublishQueueName = "results";
        private readonly string CustomerServiceListenQueueName = "customers";
        public void GetAllCustomers()
        {
            var factory = new ConnectionFactory()
            {
                HostName = RMQHostName
            };

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(queue: CustomerServiceListenQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var message = new Message<string>(1, CustomerServiceListenQueueName, CustomerServicePublishQueueName, "GetAllCustomers");
                
                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                             routingKey: CustomerServiceListenQueueName,
                             basicProperties: null,
                             body: body);
                Console.WriteLine(" [x] Sent {0}", message);

            }
        }
    }
}

