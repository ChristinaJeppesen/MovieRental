using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MovieMicroService.Models;

namespace MovieMicroService.Services
{
    public interface IMovieService
    {
        public List<Movie> GetAllMovies(IConfiguration config);
        public List<Movie> SearchMovies(IConfiguration config, string pattern);
        public List<Movie> SearchMovieById(IConfiguration config, string movieId);
    }
}
