using System.Text.Json.Serialization;

namespace SharedModelLibrary
{
    public class Movie
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int ReleaseYear { get; set; }
        public double Duration { get; set; }
        public string AgeRating { get; set; }
        public string Category { get; set; }
        public double Price { get; set; }

        [JsonConstructor]
        public Movie()
        {
        }
        public Movie(int id, string title)
        {
            Id = id;
            Title = title;
        }
    }
}
