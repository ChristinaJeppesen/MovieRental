using System;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MessageService.Models;
using System.Text.Json;
using System.Text;
using System.Text.RegularExpressions;

namespace MessageService.Service
{
    public class CustomerService : IMessageCustomer
    {

        private readonly string OutQueueName = "customers";
        private readonly string InQueueName = "results_customers";
        private readonly string RMQHostName = "rabbitmq";

        public void GetAllCustomers()
        {
            var factory = new ConnectionFactory()
            {
                HostName = RMQHostName
            };

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(queue: OutQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var message = new Message(1, "customers", "results_customers", "GetAllCustomers");
                
                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                             routingKey: OutQueueName,
                             basicProperties: null,
                             body: body);
                Console.WriteLine(" [x] Sent {0}", message);

            }
        }

        public string GetResults()
        {
            var messageRes = "";
            var factory = new ConnectionFactory()
            {
                HostName = RMQHostName
            };

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(queue: InQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var consumer = new EventingBasicConsumer(channel);
                consumer.Received += (model, ea) =>
                {
                    var body = ea.Body.ToArray();
                    var message = Encoding.UTF8.GetString(body);

                    messageRes = message;
                    Console.WriteLine(" [x] Received {0}", message);
                };
                string tag = channel.BasicConsume(queue: InQueueName,
                                     autoAck: true,
                                     consumer: consumer);

                //Console.WriteLine(" Press [enter] to exit.");
                //Console.ReadLine();
                channel.BasicCancel(tag);
            }
            return messageRes;

        }
    }
}

