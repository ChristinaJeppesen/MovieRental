using System;

namespace MovieMicroService.Models
{
    public class MovieMessage <T>
    {
        public int Id { get; set; } //like request id
        public string ListenQueueName { get; set; }
        public string PublishQueueName { get; set; }
        public string FunctionToExecute { get; set; }
        public T Arguments { get; set; }
    }
}
