using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc;

namespace SharedModelLibrary
{
    public class Worker : BackgroundService
    {
        private readonly IController _controller;
        private string ListenQueueName;

        //private const string ListenQueueName;

        public Worker(IController controller, string listenQueueName)
        {
            _controller = controller;
            ListenQueueName = listenQueueName;
        }

     

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {

            System.Threading.Thread.Sleep(30000);
            var factory = new ConnectionFactory { HostName = "rabbitmq" };
            factory.UserName = "guest";
            factory.Password = "guest";
            var connection = factory.CreateConnection();
            var channel = connection.CreateModel();

            channel.BasicQos(0, 1, false);


            channel.QueueDeclare(queue: "results",
                                   durable: false, 
                                   exclusive: false,
                                   autoDelete: false,
                                   arguments: null);

            channel.QueueDeclare(queue: ListenQueueName,
                                   durable: false, 
                                   exclusive: false,
                                   autoDelete: false,
                                   arguments: null);

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += (sender, ea) =>
            {
                var inBody = ea.Body.ToArray();
                var inMessage = Encoding.UTF8.GetString(inBody);

                var outMessage = _controller.MessageReceived(inMessage);
                var outBody = Encoding.UTF8.GetBytes(outMessage.Item2);

                channel.BasicPublish(exchange: "", routingKey: outMessage.Item1, basicProperties: null, body: outBody);

                channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            };

            channel.BasicConsume(queue: ListenQueueName,
                                    autoAck: false,
                                    consumer: consumer);

            Console.WriteLine(" Press [enter] to exit.");
            Console.ReadLine();
        }

      
    }
}




