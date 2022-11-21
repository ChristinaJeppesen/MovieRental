using System;
namespace MessageService.Models
{

    public class Message
    {
        public int Id { get; set; } //like request id
        public string InQueueName { get; set; } // where to publish
        public string OutQueueName { get; set; } // where to listen for reply
        public string FunctionToExecute { get; set; }
        public Tuple<string, string> Columns { get; set; }
    }
}



