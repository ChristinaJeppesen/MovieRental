using System;
namespace CustomerMicroService.Models
{
    public class CustomerMessage
    {
        public int Id { get; set; }
        public string ListenQueueName { get; set; }
        public string PublishQueueName { get; set; }
        public string FunctionToExecute { get; set; }
        public string Pattern { get; set; }
    }
}

