using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using System.Text;
using MessageMicroService.Models;
using SharedModelLibrary;


namespace MessageMicroService.Services
{
    public partial class MessageService : IMessageService
    {
        private readonly string BillServicePublishQueueName = "results";
        private readonly string BillServiceListenQueueName = "bills";


        public void GetCustomerBills(Guid customerId)
        {
            Message<Guid> message = new Message<Guid>(1, BillServiceListenQueueName, BillServicePublishQueueName, "GetCustomerBills", customerId);
            message.PublishMessageRMQ();
        }
        public void CreateCustomerBill(Bill bill)
        {
            Message<Bill> message = new Message<Bill>(1, BillServiceListenQueueName, BillServicePublishQueueName, "CreateCustomerBill", bill);
            message.PublishMessageRMQ();
        }

        public void UpdateCustomerBill(Bill bill)
        {
            Message<Bill> message = new Message<Bill>(1, BillServiceListenQueueName, BillServicePublishQueueName, "UpdateCustomerBill", bill);
            message.PublishMessageRMQ();
        }
    }
}
