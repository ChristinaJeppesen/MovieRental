using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using System.Text;
using MessageMicroService.Models;


namespace MessageMicroService.Services
{
    public partial class MessageService : IMessageService
    {
        private readonly string BillServicePublishQueueName = "results";
        private readonly string BillServiceListenQueueName = "bills";


        public void GetCustomerBills()
        {
            var factory = new ConnectionFactory()
            {
                HostName = RMQHostName
            };

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(queue: BillServiceListenQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                // TODO ID should come from ocelot if needed else remove
                var message = new Message<string>(1, BillServiceListenQueueName, BillServicePublishQueueName, "GetCustomerBills");

                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                     routingKey: BillServiceListenQueueName,
                                     basicProperties: null,
                                     body: body);
            }
        }
        public void CreateBill(Bill bill)
        {
            var factory = new ConnectionFactory()
            {
                HostName = RMQHostName
            };

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(queue: BillServiceListenQueueName,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                // TODO ID should come from ocelot if needed else remove
                var message = new Message<Bill>(1, BillServiceListenQueueName, BillServicePublishQueueName, "CreateBill", bill);

                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

                channel.BasicPublish(exchange: "",
                                                 routingKey: BillServiceListenQueueName,
                                                 basicProperties: null,
                                                 body: body);
            }
        }
    }
}
