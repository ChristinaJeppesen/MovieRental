using System;
using System.Text.Json.Serialization;

namespace SharedModelLibrary
{
    public class HistoryItem
    {
        //Guid CustomerId { get; set; }

        public int MovieId { get; set; }

        public string? Title { get; set; }

        public DateTime Timestamp { get; set; }

        [JsonConstructor]
        public HistoryItem()
        {
        }

        public HistoryItem(int MovieId, string Title, DateTime Timestamp)
        {
            this.MovieId = MovieId;
            this.Title = Title;
            this.Timestamp = Timestamp;
        }

        public HistoryItem(int MovieId, DateTime Timestamp)
        {
            this.MovieId = MovieId;
            this.Timestamp = Timestamp;
        }

        public HistoryItem(int MovieId, string Title)
        {
            this.MovieId = MovieId;
            this.Title = Title;
        }

    }


}
