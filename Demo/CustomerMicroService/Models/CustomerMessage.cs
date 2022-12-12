using System;
namespace CustomerMicroService.Models
{
    public class CustomerMessage <T>
    {
        public int Id { get; set; }
        public string ListenQueueName { get; set; }
        public string PublishQueueName { get; set; }
        public string FunctionToExecute { get; set; }
        public T Arguments { get; set; }

        public CustomerMessage(int id, string listenQueueName, string publishQueueName, string functionToExecute, T arguments)
        {
            Id = id;
            ListenQueueName = listenQueueName;
            PublishQueueName = publishQueueName;
            FunctionToExecute = functionToExecute;
            Arguments = arguments;
        }
    }
}

