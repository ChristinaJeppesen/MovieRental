using Microsoft.AspNetCore.Mvc;
using MovieService.Models;
using MovieService.Service;
using MovieService;
using System.Text.Json;
using Microsoft.Extensions.Logging;

namespace MovieService.Controller
{

    [Route("[controller]")]
    [Controller]
    public class MovieController : ControllerBase
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

        public (string, List<Movie>) MessageRecieved(string inMessage)
        {
            Console.WriteLine(" - Message Recieved");

            var list = new List<Movie>();
            Console.WriteLine(inMessage);
            MovieMessage? movieMessage = JsonSerializer.Deserialize<MovieMessage>(inMessage);

            if (movieMessage.FunctionToExecute == "GetAllMovies")
            {
                list = _movieService.GetAllMovies(_config);
            }
            
            else if (movieMessage.FunctionToExecute == "SearchMovies")
            {
                list = _movieService.SearchMovies(_config, movieMessage.Pattern);
            }

            return (movieMessage.PublishQueueName, list);

        }

    }
}

