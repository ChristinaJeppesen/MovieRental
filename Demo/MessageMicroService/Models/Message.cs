using System;
namespace MessageMicroService.Models
{

    public class Message<T> 
    {
        public int Id { get; set; } //like request id
        public string ListenQueueName { get; set; } 
        public string PublishQueueName { get; set; } 
        public string FunctionToExecute { get; set; }
        public T? Arguments { get; set; }

        // Different ways of constructing a Message object
        public Message(int id, string listenQueueName,string publishQueueName, string functionToExecute, T arguments)
        {
            Id = id;
            ListenQueueName = listenQueueName;
            PublishQueueName = publishQueueName;
            FunctionToExecute = functionToExecute;
            Arguments = arguments;
        }

        public Message(int id, string listenQueueName, string publishQueueName, string functionToExecute)
        {
            Id = id;
            ListenQueueName = listenQueueName;
            PublishQueueName = publishQueueName;
            FunctionToExecute = functionToExecute;
        }


    }
}



