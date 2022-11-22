using System;
namespace MessageService.Models
{

    public class Message
    {
        public int Id { get; set; } //like request id
        public string ?ListenQueueName { get; set; } 
        public string ?PublishQueueName { get; set; } 
        public string ?FunctionToExecute { get; set; } 
        public string ?Pattern { get; set; }
    }
}



