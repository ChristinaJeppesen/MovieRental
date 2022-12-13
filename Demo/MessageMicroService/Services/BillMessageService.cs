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


        public void GetCustomerBills()
        {
            Message<string> message = new Message<string>(1, BillServiceListenQueueName, BillServicePublishQueueName, "GetCustomerBills", null);
            message.PublishMessageRMQ();

        }
        public void CreateBill(Bill bill)
        {

            Message<Bill> message = new Message<Bill>(1, BillServiceListenQueueName, BillServicePublishQueueName, "CreateBill", bill);
            message.PublishMessageRMQ();

        }
    }
}
