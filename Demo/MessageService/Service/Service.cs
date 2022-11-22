using MessageService.Models;
using RabbitMQ.Client;
using System.Text.Json;
using System.Text;
using RabbitMQ.Client.Events;

namespace MessageService.Service
{
    public class Service : IMessageService
    {
        private readonly string MessagePublishQueueName = "movies";
        private readonly string MessageListenQueueName = "results";
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
                channel.QueueDeclare(queue: MessagePublishQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var message = new Message
                {
                    Id = 1, // this ID should come from ocelot if needed
                    ListenQueueName = "movies",
                    PublishQueueName = "results",
                    FunctionToExecute = "GetAllMovies",
                    Pattern = ""
                };

                Console.WriteLine(message);

                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                     routingKey: MessagePublishQueueName,
                                     basicProperties: null,
                                     body: body);
                Console.WriteLine(" [x] Sent {0}", message);
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
                channel.QueueDeclare(queue: MessagePublishQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var message = new Message
                {
                    Id = 1,
                    ListenQueueName = "movies",
                    PublishQueueName = "results",
                    FunctionToExecute = "SearchMovies",
                    Pattern = pattern
                };



                Console.WriteLine(message);

                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                     routingKey: MessagePublishQueueName,
                                     basicProperties: null,
                                     body: body);
                Console.WriteLine(" [x] Sent {0}", message);
            }

            //var list = new List<string>();
            //list.Add(("hej"));
            //return list;
        }
        public void GetAllCostumers()
        {
            Console.WriteLine();
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
                channel.QueueDeclare(queue: MessageListenQueueName,
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
                string tag = channel.BasicConsume(queue: MessageListenQueueName,
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
