using MessageMicroService.Models;
using RabbitMQ.Client;
using System.Text.Json;
using System.Text;
using RabbitMQ.Client.Events;
using SharedModelLibrary;

namespace MessageMicroService.Services
{
    public partial class MessageService : IMessageService
    {
        private readonly string MovieServicePublishQueueName = "results";
        private readonly string MovieServiceListenQueueName = "movies";
        
        public void GetAllMovieList()
        {

            Message<string> message = new(1, MovieServiceListenQueueName, MovieServicePublishQueueName, "GetAllMovies", null);
            message.PublishMessageRMQ();
            
        }

        public void GetFilteredMovieList(string arguments)
        {

            Message<string> message = new(1, MovieServiceListenQueueName, MovieServicePublishQueueName, "SearchMovies", arguments);
            message.PublishMessageRMQ();
        }

        public void GetMovieById(int movieId)
        {

            Message<int> message = new(1, MovieServiceListenQueueName, MovieServicePublishQueueName, "SearchMovieById", movieId);
            message.PublishMessageRMQ();
        }
    }
}
