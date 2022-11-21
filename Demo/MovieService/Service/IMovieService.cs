using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MovieService.Models;

namespace MovieService.Service
{

    public interface IMovieService

    {
        public List<Movie> GetAllMovies(IConfiguration config);
        public List<Movie> SearchMovies(IConfiguration config, string item1, string item2);
    }
}
