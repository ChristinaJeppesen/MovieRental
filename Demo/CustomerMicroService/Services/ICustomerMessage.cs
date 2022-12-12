using System;
using CustomerMicroService.Models;

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

    }
}

