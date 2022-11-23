namespace MessageMicroService.Services
{
    public interface IMessageService
    {
        // Movies 
        public void GetAllMovieList();
        public void GetFilteredMovieList(string pattern);
        public void GetMovieById(string movieId);

        // Customers 
        public void GetAllCustomers();

        // Results 
        public string GetResults();
    }
}
