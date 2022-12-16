using Microsoft.AspNetCore.Mvc;
using MovieMicroService.Models;
using MovieMicroService.Services;
using MovieMicroService;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using SharedModelLibrary;

namespace MovieMicroService.Controller
{
    public class MovieController : SharedModelLibrary.Controller
    {
        private readonly ILogger<MovieController> _logger;
        private readonly IMovieService _movieService;
        private readonly IConfiguration _config;

        public MovieController(ILogger<MovieController> logger, IMovieService movieService, IConfiguration config)
        {
            _logger = logger;
            _movieService = movieService;
            _config = config;
        }

        public override (string, string) MessageReceived(string inMessage)
        {
            Console.WriteLine(" - Message Recieved");
            dynamic response = null;

            Message<dynamic>? movieMessage = JsonSerializer.Deserialize<Message<dynamic>>(inMessage);

            if (movieMessage.FunctionToExecute == "GetAllMovies")
            {
                response = _movieService.GetAllMovies(_config);
            }           
            else if (movieMessage.FunctionToExecute == "SearchMovies")
            {
                string pattern = JsonSerializer.Deserialize<string>(movieMessage.Arguments);
                response = _movieService.SearchMovies(_config, pattern);
            }            
            else if (movieMessage.FunctionToExecute == "SearchMovieById")
            {
                int movieId = JsonSerializer.Deserialize<int>(movieMessage.Arguments);
                response = _movieService.SearchMovieById(_config, movieId);
            }
            else if (movieMessage.FunctionToExecute == "GetMovieTitles")
            {
                List<int> movieIdList = JsonSerializer.Deserialize<List<int>>(movieMessage.Arguments);
                response = _movieService.GetMovieTitles(_config, movieIdList);
            }

            return (movieMessage.PublishQueueName, JsonSerializer.Serialize(response));
        }
    }
}
