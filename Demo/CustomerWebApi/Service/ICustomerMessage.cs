using System;
using CustomerWebApi.Models;

namespace CustomerWebApi.Service
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

        }
}

