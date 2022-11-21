using System;
namespace CustomerWebApi.Models
{
    public class CustomerMessage
    {
        public int Id { get; set; }

        public string QueueName { get; set; }

        public string FunctionToExecute { get; set; }

        public Tuple<string, string> Columns { get; set; }
    }
}

