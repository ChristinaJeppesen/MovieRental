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
        public void UpdateCustomerInformation(Customer customerId);
        public void GetCustomerHistoryList(Guid customerId);

        // Bills 
        public void CreateCustomerBill(Bill bill);
        public void GetCustomerBills(Guid customerId);
        public void UpdateCustomerBill(Bill bill);

        // Results 
        public string GetResults();
    }
}
