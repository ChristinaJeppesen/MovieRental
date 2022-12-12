using MessageMicroService.Models;

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


        // Bills 
        public void CreateBill(Bill bill);
        void GetCustomerBills();
        
        // Results 
        public string GetResults();
    }
}
