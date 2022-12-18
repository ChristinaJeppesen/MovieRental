using System;
using CustomerMicroService.Models;
using SharedModelLibrary;

namespace CustomerMicroService.Services
{
    public interface ICustomerMessage
    {

        public List<Customer> GetAllCustomers(IConfiguration config);

        public Customer GetCustomer(IConfiguration config);

        //To be implemented
        /*
        public void DeleteCustomer(IConfiguration config);

        public void CreateCustomer(IConfiguration config);
        */

        /*Customer movie stuff*/

        public int AddMovieToWatchList(IConfiguration config, WatchList arguments);
        List<int> GetCustomerWatchListById(IConfiguration config, Guid customerId);
        int UpdateCustomerInformation(IConfiguration config, Customer customer);
        public List<HistoryItem> GetCustomerHistoryList(IConfiguration config, Guid customerId);
    }
}

