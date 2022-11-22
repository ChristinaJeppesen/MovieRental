using System;
namespace MessageMicroService.Models
{

    public class Message
    {
        public int Id { get; set; } //like request id
        public string ListenQueueName { get; set; } 
        public string PublishQueueName { get; set; } 
        public string FunctionToExecute { get; set; }
        public string Pattern { get; set; }

        // Different ways of constructing a Message object
        public Message(int id, string listenQueueName,string publishQueueName, string functionToExecute, string _pattern)
        {
            Id = id;
            ListenQueueName = listenQueueName;
            PublishQueueName = publishQueueName;
            FunctionToExecute = functionToExecute;
            Pattern = _pattern;
        }

        public Message(int id, string listenQueueName, string publishQueueName, string functionToExecute)
        {
            Id = id;
            ListenQueueName = listenQueueName;
            PublishQueueName = publishQueueName;
            FunctionToExecute = functionToExecute;
            Pattern = string.Empty;
        }



    }
}



