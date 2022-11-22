using System;
using CustomerMicroService.Models;
using Npgsql;

namespace CustomerMicroService.Services
{
    public class CustomerService : ICustomerMessage
    {
       
        public List<Customer> GetAllCustomers(IConfiguration config)
        {
            var customerList = new List<Customer>();
            string conn = config.GetConnectionString("DefaultConnection");

            using (NpgsqlConnection myCon = new NpgsqlConnection(conn))
            {
                myCon.Open();
                using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM customer", myCon))
                {

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        Customer customer = new Customer(reader.GetGuid(0), reader.GetString(1),reader.GetString(2), reader.GetString(3), reader.GetInt32(4));
                        customerList.Add(customer);

                    }
                    reader.Close();
                }
            }
            return customerList;
        }

     
        public Customer GetCustomer(IConfiguration config)
        {
            throw new NotImplementedException();
        }
    }
}

