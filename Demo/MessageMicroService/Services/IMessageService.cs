using MessageMicroService.Models;
using SharedModelLibrary;

namespace MessageMicroService.Services
{
    public interface IMessageService
    {
        // Movies 
        public void GetAllMovieList();
        public void GetFilteredMovieList(string pattern);
        public void GetMovieById(int movieId);

        // Customers 
        public void GetAllCustomers();
        public void AddMovieToWatchList(WatchList watchList);
        public void GetCustomerWatchListById(Guid customerId);


        // Bills 
        public void CreateBill(Bill bill);
        public void GetCustomerBills();
        
        // Results 
        public string GetResults();
    }
}
