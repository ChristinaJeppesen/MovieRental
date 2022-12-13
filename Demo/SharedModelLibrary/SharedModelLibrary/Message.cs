using System;
using System.Text.Json;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace SharedModelLibrary
{

    public class Message<T>
    {
        private readonly string RMQHostName = "rabbitmq";
        public int Id { get; set; } //like request id
        public string ListenQueueName { get; set; }
        public string PublishQueueName { get; set; }
        public string FunctionToExecute { get; set; }
        public T? Arguments { get; set; }

        // Different ways of constructing a Message object
        public Message(int id, string listenQueueName, string publishQueueName, string functionToExecute, T? arguments)
        {
            Id = id;
            ListenQueueName = listenQueueName;
            PublishQueueName = publishQueueName;
            FunctionToExecute = functionToExecute;
            Arguments = arguments;
        }

        public void PublishMessageRMQ()
        {
            var factory = new ConnectionFactory()
            {
                HostName = RMQHostName
            };

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(queue: ListenQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                // TODO ID should come from ocelot if needed else remove
                var message = new Message<T>(1, ListenQueueName, PublishQueueName, FunctionToExecute, Arguments);

                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                     routingKey: ListenQueueName,
                                     basicProperties: null,
                                     body: body);
            }
        }

    }
}



