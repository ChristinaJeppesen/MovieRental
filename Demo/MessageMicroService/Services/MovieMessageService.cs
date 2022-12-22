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

            Message<string> message = new(MovieServiceListenQueueName, MovieServicePublishQueueName, "GetAllMovies", null);
            message.PublishMessageRMQ();
            
        }

        public void GetFilteredMovieList(string arguments)
        {

            Message<string> message = new(MovieServiceListenQueueName, MovieServicePublishQueueName, "BrowseMovies", arguments);
            message.PublishMessageRMQ();
        }

        public void GetMovieById(int movieId)
        {

            Message<int> message = new(MovieServiceListenQueueName, MovieServicePublishQueueName, "GetMovieById", movieId);
            message.PublishMessageRMQ();
        }
    }
}
