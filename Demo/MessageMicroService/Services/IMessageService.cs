namespace MessageMicroService.Services
{
    public interface IMessageService
    {
        // Movies 
        public void GetAllMovieList();
        public void GetFilteredMovieList(string pattern);

        // Customers 
        public void GetAllCustomers();

        // Results 
        public string GetResults(); 
    }
}
