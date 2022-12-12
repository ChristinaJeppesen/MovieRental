using MovieMicroService.Models;
using Npgsql;
// Service + data access layer combined 

namespace MovieMicroService.Services
{
    public class MovieService : IMovieService
    {
        public List<Movie> GetAllMovies(IConfiguration config)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - GetAllMovies() enabled");
            var movieList = new List<Movie>();

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                using (var command = new NpgsqlCommand("SELECT movie_id,title,description,release_year,duration,rating,price " +
                                                       "FROM movie JOIN movie_price " +
                                                       "ON movie.price_id=movie_price.price_id", conn))
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
                            Price = reader.GetDouble(6)
                        };
                        movieList.Add( movie );
                    };
                    reader.Close();
                    Console.Out.WriteLine("   - Connection closed");
                }
            }
            return movieList;
        }

        
        public List<Movie> SearchMovies(IConfiguration config, string pattern)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - SearchMovies() enabled");
            var movieList = new List<Movie>();

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                using (var command = new NpgsqlCommand($"SELECT movie_id,title,description,release_year,duration,rating,price " +
                                                       $"FROM movie JOIN movie_price " +
                                                       $"ON movie.price_id=movie_price.price_id " +
                                                       $"WHERE title LIKE '%{pattern}%' OR description LIKE '%{pattern}%'", conn))
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
                            Price = reader.GetDouble(6)
                        };
                        movieList.Add(movie);
                    };
                    reader.Close();
                    Console.Out.WriteLine("   - Connection closed");
                }
            }
            return movieList;
        }

        public List<Movie> SearchMovieById(IConfiguration config, int movieId)
        {
            string connString = config.GetConnectionString("DefaultConnection");
            List<Movie> movieList = new();

            Console.WriteLine(" - SearchMovieById() enabled");

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                using (var command = new NpgsqlCommand($"SELECT movie_id,title,description,release_year,duration,rating,price " +
                                                       $"FROM movie JOIN movie_price " +
                                                       $"ON movie.price_id=movie_price.price_id " +
                                                       $"WHERE movie_id={movieId}", conn))
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
                        Price = reader.GetDouble(6)
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

            Console.Out.WriteLine(" - GetMovieTitles() enabled");
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

