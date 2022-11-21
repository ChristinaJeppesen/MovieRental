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

        // Different ways of constructing a Message object

        public Message(int _id, string _inQueueName,string _OutQueueName, string _functionToExecute, Tuple<string, string> _columns)
        {
            Id = _id;
            InQueueName = _inQueueName;
            OutQueueName = _OutQueueName;
            FunctionToExecute = _functionToExecute;
            Columns = _columns;
        }

        public Message(int _id, string _inQueueName, string _OutQueueName, string _functionToExecute)
        {
            Id = _id;
            InQueueName = _inQueueName;
            OutQueueName = _OutQueueName;
            FunctionToExecute = _functionToExecute;
        }



    }
}



