using MessageMicroService.Models;
using RabbitMQ.Client;
using System.Text.Json;
using System.Text;
using RabbitMQ.Client.Events;

namespace MessageMicroService.Services
{
    public partial class MessageService : IMessageService
    {
        private readonly string MovieServicePublishQueueName = "results";
        private readonly string MovieServiceListenQueueName = "movies";
        
        public void GetAllMovieList()
        {
            var factory = new ConnectionFactory()
            {
                HostName = RMQHostName
            };

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(queue: MovieServiceListenQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                // ID should come from ocelot if needed else remove
                var message = new Message(1, MovieServiceListenQueueName, MovieServicePublishQueueName, "GetAllMovies"); 
          
                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                     routingKey: MovieServiceListenQueueName,
                                     basicProperties: null,
                                     body: body);
            }
        }

        public void GetFilteredMovieList(string pattern)
        {
            var factory = new ConnectionFactory()
            {
                HostName = RMQHostName
            };

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(queue: MovieServiceListenQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var message = new Message(1, MovieServiceListenQueueName, MovieServicePublishQueueName, "SearchMovies", pattern);
               
                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                     routingKey: MovieServiceListenQueueName,
                                     basicProperties: null,
                                     body: body);
                Console.WriteLine(" [x] Sent {0}", message);
            }
        }
    }
}
