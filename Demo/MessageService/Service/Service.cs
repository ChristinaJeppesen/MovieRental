﻿using MessageService.Models;
using RabbitMQ.Client;
using System.Text.Json;
using System.Text;
using RabbitMQ.Client.Events;

namespace MessageService.Service
{
    public class Service : IMessageService
    {
        private readonly string OutQueueName = "movies";
        private readonly string InQueueName = "results";
        private readonly string RMQHostName = "rabbitmq";
        
        public void GetAllMovieList()
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

                var message = new Message(1, "movie", "results", "GetAllMovies", Tuple.Create("Title", "terminator"));
          
                Console.WriteLine(message);

                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                     routingKey: OutQueueName,
                                     basicProperties: null,
                                     body: body);
                Console.WriteLine(" [x] Sent {0}", message);
            }

            //var list = new List<string>();
            //list.Add(("hej"));
            //return list;
        }

        public void GetFilteredMovieList(string filter, string match)
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

                var message = new Message(1, "movie", "results", "SearchMovies", Tuple.Create(filter, match));
               
                Console.WriteLine(message);

                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                     routingKey: OutQueueName,
                                     basicProperties: null,
                                     body: body);
                Console.WriteLine(" [x] Sent {0}", message);
            }

            //var list = new List<string>();
            //list.Add(("hej"));
            //return list;
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
