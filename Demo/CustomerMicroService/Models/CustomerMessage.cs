using System;
namespace CustomerMicroService.Models
{
    public class CustomerMessage<T>
    {
        public int Id { get; set; }
        public string ListenQueueName { get; set; }
        public string PublishQueueName { get; set; }
        public string FunctionToExecute { get; set; }
        public T? Arguments { get; set; }
    }
}

