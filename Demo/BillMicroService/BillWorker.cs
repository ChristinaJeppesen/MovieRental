using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using BillMicroService.Controller;
using Microsoft.EntityFrameworkCore.Query;
using SharedModelLibrary;

namespace BillMicroService
{
    public class BillWorker : BackgroundService
    {
        private readonly ILogger<BillWorker> _logger;
        private readonly BillController _billController;
        private const string ListenQueueName = "bills";

        public BillWorker(ILogger<BillWorker> logger, BillController billController)
        {
            _logger = logger;
            _billController = billController;
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
                var outMessage = _billController.MessageRecieved(inMessage);
                Console.WriteLine(outMessage.Item2);
                var outBody = Encoding.UTF8.GetBytes(outMessage.Item2);
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




