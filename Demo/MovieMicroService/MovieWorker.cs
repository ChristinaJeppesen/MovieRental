using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using RabbitMQ.Client.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System.Threading.Channels;
using MovieMicroService.Models;
using System.Text.Json;
using Microsoft.AspNetCore.Connections;
using MovieMicroService.Controller;

namespace MovieMicroService
{
    public class MovieWorker : SharedModelLibrary.Worker
    {
        private readonly MovieController movieController;
        private const string listenQueueName = "movies";

        public MovieWorker(MovieController movieController, string listenQueueName) :
            base(movieController, listenQueueName)
        {
        }

    }
}




