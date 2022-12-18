using System;
using System.Collections.Generic;
using System.Xml.Linq;
using CustomerMicroService.Models;
using Microsoft.AspNetCore.Mvc;
using Npgsql;
using SharedModelLibrary;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

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
                        Customer customer = new Customer(reader.GetGuid(0), reader.GetString(1),reader.GetString(2), reader.GetString(3));
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

        public int UpdateCustomerInformation(IConfiguration config, Customer customer)
        {
            Customer cur_customer_info = new Customer ();
            Console.WriteLine("CustomerService: UpdateCustomerInformation()");
            var result = -1;
            var customer_id = customer.Id;
            var new_first_name = customer.FirstName;
            var new_last_name = customer.LastName;
            var new_email = customer.Email;
            string conn = config.GetConnectionString("DefaultConnection");

            using (NpgsqlConnection myCon = new NpgsqlConnection(conn))
            {
                myCon.Open();
                using (NpgsqlCommand command = new NpgsqlCommand($"SELECT * FROM customer WHERE customer_id='{customer_id}'", myCon))
                {
                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        Customer ccustomer = new(reader.GetGuid(0), reader.GetString(1), reader.GetString(2), reader.GetString(3));
                        cur_customer_info = ccustomer;
                    }

                    reader.Close();
                }
            }
         
            string firstname = new_first_name == "" ? cur_customer_info.FirstName : new_first_name;
            string lastname = new_last_name == "" ? cur_customer_info.LastName : new_last_name;
            string email = new_email == "" ? cur_customer_info.Email : new_email;

            var query = $"UPDATE customer set first_name='{firstname}', last_name='{lastname}', email='{email}' WHERE customer_id='{customer_id}' ";

            using (NpgsqlConnection myCon = new NpgsqlConnection(conn))
            {
                Console.WriteLine("Opening connection");
                myCon.Open();
                using (NpgsqlCommand command = new NpgsqlCommand(query, myCon))
                {
                    result = command.ExecuteNonQuery();
                }
            }
            return result;

        }

        public List<HistoryItem> GetCustomerHistoryList(IConfiguration config, Guid customer_id)
        {
            List<HistoryItem> result = new();
            string conn = config.GetConnectionString("DefaultConnection");
            using (NpgsqlConnection myCon = new NpgsqlConnection(conn))
            {
                myCon.Open();
                using (NpgsqlCommand command = new NpgsqlCommand($"SELECT movie_id, timestamp FROM history_list WHERE customer_id='{customer_id}'", myCon))
                {
                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        HistoryItem temp = new(reader.GetInt32(0), reader.GetDateTime(1));
                        result.Add(temp);
                    }

                    reader.Close();
                }
            }
            return result;
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

        }
        */
    }
}

