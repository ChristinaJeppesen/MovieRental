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

        public List<Movie> MessageRecieved(string inMessage)
        {
            Console.WriteLine(" - Message Recieved");

            var list = new List<Movie>();

            MovieMessage? movieMessage = JsonSerializer.Deserialize<MovieMessage>(inMessage);

            if (movieMessage.FunctionToExecute == "GetAllMovies")
            {
                Console.WriteLine("Hello from the code");
                list = _movieService.GetAllMovies(_config);
            }
            
            else if (movieMessage.FunctionToExecute == "SearchMovies")
            {
                list = _movieService.SearchMovies(_config, movieMessage.Columns.Item1, movieMessage.Columns.Item2);
            }

            return list;

        }

    }
}

