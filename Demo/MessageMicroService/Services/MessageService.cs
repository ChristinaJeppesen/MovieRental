using MessageMicroService.Models;
using RabbitMQ.Client;
using System.Text.Json;
using System.Text;
using RabbitMQ.Client.Events;

namespace MessageMicroService.Services
{
    public partial class MessageService : IMessageService
    {
        private readonly string MessageListenQueueName = "results";
        private readonly string RMQHostName = "rabbitmq";
        
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
