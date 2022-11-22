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
using MovieMicroService.Models;
using System.Text.Json;
using Microsoft.AspNetCore.Connections;
using MovieMicroService.Controller;

namespace MovieMicroService
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly MovieController _movieController;
        private const string ListenQueueName = "movies";

        public Worker(ILogger<Worker> logger, MovieController movieController)
        {
            _logger = logger;
            _movieController = movieController;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation($"Queue [{ListenQueueName}] is waiting for messages.");
            System.Threading.Thread.Sleep(30000);
            var factory = new ConnectionFactory { HostName = "rabbitmq" };
            factory.UserName = "guest";
            factory.Password = "guest";
            var connection = factory.CreateConnection();
            var inChannel = connection.CreateModel();
            var outChannel = connection.CreateModel();

            inChannel.BasicQos(0, 1, false);
            
            //outChannel.BasicQos(0, 1, false); // dosent seem to make diff


            inChannel.QueueDeclare(queue: ListenQueueName,
                                   durable: false, // true if sender's durable is true!!!
                                   exclusive: false,
                                   autoDelete: false,
                                   arguments: null);

            var consumer = new EventingBasicConsumer(inChannel);
            consumer.Received += (sender, ea) =>
            {
                var inBody = ea.Body.ToArray();
                var inMessage = Encoding.UTF8.GetString(inBody);

                // publish result on outChannel and keep listening for more messages
                var outMessage = _movieController.MessageRecieved(inMessage);
                var outBody = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(outMessage.Item2));
               
                outChannel.QueueDeclare(queue: outMessage.Item1, // dosent seem to make diff??
                                   durable: false, // true if sender's durable is true!!!
                                   exclusive: false,
                                   autoDelete: false,
                                   arguments: null);
                outChannel.BasicPublish(exchange: "", routingKey: outMessage.Item1, basicProperties: null, body: outBody);

                inChannel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            };

            inChannel.BasicConsume(queue: ListenQueueName,
                                    autoAck: false,
                                    consumer: consumer);

            Console.WriteLine(" Press [enter] to exit.");
            Console.ReadLine();
        }

    }
}




