using Microsoft.Extensions.FileSystemGlobbing.Internal;
using MovieMicroService.Models;
using Npgsql;
using SharedModelLibrary;
using System.ComponentModel;
using System.Data;
// Service + data access layer combined 

namespace MovieMicroService.Services
{
    public class MovieService : IMovieService
    {
        public List<Movie> GetAllMovies(IConfiguration config)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - GetAllMovies()");
            var movieList = new List<Movie>();

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                var query = "SELECT movie.movie_id, title, description, release_year, duration, rating, category.name, price " +
                            "FROM movie JOIN movie_category ON movie.movie_id = movie_category.movie_id " +
                            "JOIN category ON category.category_id = movie_category.category_id " +
                            "JOIN movie_price ON movie_price.price_id = movie.price_id";

                using (var command = new NpgsqlCommand(query, conn))
                {
                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        Movie movie = new()
                        {
                            Id = reader.GetInt32(0),
                            Title = reader.GetString(1),
                            Description = reader.GetString(2),
                            ReleaseYear = reader.GetInt32(3),
                            Duration = reader.GetDouble(4),
                            AgeRating = reader.GetString(5),
                            Category = reader.GetString(6),
                            Price = reader.GetDouble(7)
                        };
                        movieList.Add( movie );
                    };
                    reader.Close();
                    Console.Out.WriteLine("   - Connection closed");
                }
            }
            return movieList;
        }

        
        public List<Movie> GetFilteredMovies(IConfiguration config, string pattern)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - GetFilteredMovies()");
            var movieList = new List<Movie>();

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                var query = $"SELECT movie.movie_id, title, description, release_year, duration,rating, category.name, price " +
                            $"FROM movie JOIN movie_category ON movie.movie_id = movie_category.movie_id " +
                            $"JOIN category ON category.category_id = movie_category.category_id " +
                            $"JOIN movie_price ON movie_price.price_id = movie.price_id " +
                            $"WHERE title ILIKE '%{pattern}%' OR description ILIKE '%{pattern}%' OR category.name ILIKE '%{pattern}%'";

                using (var command = new NpgsqlCommand(query, conn))
                {
                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        Movie movie = new()
                        {
                            Id = reader.GetInt32(0),
                            Title = reader.GetString(1),
                            Description = reader.GetString(2),
                            ReleaseYear = reader.GetInt32(3),
                            Duration = reader.GetDouble(4),
                            AgeRating = reader.GetString(5),
                            Category = reader.GetString(6),
                            Price = reader.GetDouble(7)
                        };
                        movieList.Add(movie);
                    };
                    reader.Close();
                    Console.Out.WriteLine("   - Connection closed");
                }
            }
            return movieList;
        }

        public List<Movie> GetMovieById(IConfiguration config, int movieId)
        {
            string connString = config.GetConnectionString("DefaultConnection");
            List<Movie> movieList = new();

            Console.WriteLine(" - SearchMovieById()");

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                var query = $"SELECT movie.movie_id, title, description, release_year, duration, rating, category.name, price " +
                            $"FROM movie JOIN movie_category ON movie.movie_id = movie_category.movie_id " +
                            $"JOIN category ON category.category_id = movie_category.category_id " +
                            $"JOIN movie_price ON movie_price.price_id = movie.price_id " +
                            $"WHERE movie.movie_id={movieId}";
                
                using (var command = new NpgsqlCommand(query, conn))
                {
                    var reader = command.ExecuteReader();
                    reader.Read();

                    // make constructer?
                    Movie movie = new()
                    {
                        Id = reader.GetInt32(0),
                        Title = reader.GetString(1),
                        Description = reader.GetString(2),
                        ReleaseYear = reader.GetInt32(3),
                        Duration = reader.GetDouble(4),
                        AgeRating = reader.GetString(5),
                        Category = reader.GetString(6),
                        Price = reader.GetDouble(7)
                    };
                    movieList.Add(movie);

                    reader.Close();
                    Console.Out.WriteLine("   - Connection closed");
                }
            }
            return movieList;
        }

        public List<string> GetMovieTitles(IConfiguration config, List<int> movieIdList)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - GetMovieTitles()");
            var movieTitleList = new List<string>();

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                var sqlMovieIdList = string.Join(",", movieIdList.Select(i => $"{i}"));
                using (var command = new NpgsqlCommand($"SELECT title FROM movie WHERE movie_id IN ({sqlMovieIdList})", conn))
                {
                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        movieTitleList.Add(reader.GetString(0));
                    };
                    reader.Close();
                    Console.Out.WriteLine("   - Connection closed");
                }
            }
            return movieTitleList;
        }
    }
}

