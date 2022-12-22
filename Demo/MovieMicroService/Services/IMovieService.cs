using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MovieMicroService.Models;
using SharedModelLibrary;

namespace MovieMicroService.Services
{
    public interface IMovieService
    {
        public List<Movie> GetAllMovies(IConfiguration config);
        public List<Movie> GetFilteredMovies(IConfiguration config, string pattern);
        public List<Movie> GetMovieById(IConfiguration config, int movieId);
        public List<Movie> GetMovieTitles(IConfiguration config, List<int> movieIdList);
        public List<HistoryItem> ConstructHistoryList(IConfiguration config, List<HistoryItem> movieIdList);

    }
}
