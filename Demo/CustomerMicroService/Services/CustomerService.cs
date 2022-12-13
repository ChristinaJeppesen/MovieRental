using System;
using System.Xml.Linq;
using CustomerMicroService.Models;
using Microsoft.AspNetCore.Mvc;
using Npgsql;
using SharedModelLibrary;

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


        public int AddMovieToWatchList(IConfiguration config, WatchList arguments)
        {
            string connString = config.GetConnectionString("DefaultConnection");
            int addedMovie = -1;
            Console.WriteLine(arguments.CustomerId);
            Console.WriteLine(arguments.Movieid);
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();

                using (NpgsqlCommand command = new NpgsqlCommand("INSERT INTO watch_list (customer_id, movie_id) VALUES (@id1, @t1)", conn))
                {
                    command.Parameters.AddWithValue("id1",arguments.CustomerId);
                    command.Parameters.AddWithValue("t1", arguments.Movieid);
                    
                    int nRows = command.ExecuteNonQuery();
                    Console.Out.WriteLine(String.Format("Number of rows inserted={0}", nRows));
                    addedMovie = nRows;
                }
            }
            return addedMovie;
        }

        public List<int> GetCustomerWatchListById(IConfiguration config, Guid customerId)
        {
            Console.WriteLine("CustomerService: GetCustomerWatchListById()");
            var movieIdList = new List<int>();
            string conn = config.GetConnectionString("DefaultConnection");

            using (NpgsqlConnection myCon = new NpgsqlConnection(conn))
            {
                Console.WriteLine("Opening connection");
                myCon.Open();
                using (NpgsqlCommand command = new NpgsqlCommand($"SELECT movie_id FROM watch_list WHERE customer_id='{customerId}'", myCon))
                {

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        movieIdList.Add(reader.GetInt32(0));

                    }
                    reader.Close();
                    Console.WriteLine("Closed connection");
                }
            }
            return movieIdList;

        }


        /*

        [HttpPost(Name = "AddCustomer")]
        public void AddCustomer([FromBody] Customer customer)
        {
            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("Opening connection");
                conn.Open();

                using (var command = new NpgsqlCommand("INSERT INTO customers (id, name, email) VALUES (@id1, @t1, @t2)", conn))
                {
                    Guid uuid = Guid.NewGuid();

                    command.Parameters.AddWithValue("id1", uuid);
                    command.Parameters.AddWithValue("t1", customer.name);
                    command.Parameters.AddWithValue("t2", customer.email);


                    int nRows = command.ExecuteNonQuery();
                    Console.Out.WriteLine(String.Format("Number of rows inserted={0}", nRows));
                }
            }
        */


    }
}

