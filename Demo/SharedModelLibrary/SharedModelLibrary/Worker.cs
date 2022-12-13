using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc;

namespace SharedModelLibrary
{
    public class Worker
    {
        private readonly Controller _controller;
        private string ListenQueueName;

        //private const string ListenQueueName;

        public Worker(Controller controller, string listenQueueName)
        {
            _controller = controller;
            ListenQueueName = listenQueueName;
        }

        public void Test()
        {

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
                
                var outMessage = _controller.MessageRecieved(inMessage);
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




