using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CustomerMicroService.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using CustomerMicroService.Services;
using Npgsql;
using System.Text.Json;
using SharedModelLibrary;
using RabbitMQ.Client.Events;
using System.Text;
using Microsoft.AspNetCore.SignalR.Protocol;

namespace CustomerMicroService.Controllers
{
    public class CustomerController : SharedModelLibrary.Controller
    {
        private readonly IConfiguration _config;
        private readonly ILogger<CustomerController> _logger;
        private readonly ICustomerMessage _customerMessage;


        public CustomerController(ILogger<CustomerController> logger, ICustomerMessage customerMessage,
            IConfiguration config)
        {
            _logger = logger;
            _customerMessage = customerMessage;
            _config = config;
            
        }

        public override (string, string) MessageReceived(string inMessage)
        {
            Console.WriteLine(" - Message Recieved");
            dynamic response = null;

            Message<dynamic>? customerMessage = JsonSerializer.Deserialize<Message<dynamic>>(inMessage);

            if (customerMessage.FunctionToExecute == "GetAllCustomers")
            {
                response = _customerMessage.GetAllCustomers(_config);
            }

            else if (customerMessage.FunctionToExecute == "GetCustomer")
            {
                response.Add(_customerMessage.GetCustomer(_config));
            }
            else if (customerMessage.FunctionToExecute == "AddMovieToWatchList")
            {

                WatchList w = JsonSerializer.Deserialize<WatchList>(customerMessage.Arguments);
                
                response = _customerMessage.AddMovieToWatchList(_config, w);

            }
            else if (customerMessage.FunctionToExecute == "GetCustomerWatchListById")
            {
                Guid customerId = JsonSerializer.Deserialize<Guid>(customerMessage.Arguments);
                
                var movieIdList = _customerMessage.GetCustomerWatchListById(_config, customerId);
                response = new Message<List<int>>("movies", "results", "GetMovieTitles", movieIdList);

            }
            else if (customerMessage.FunctionToExecute == "GetCustomerHistoryList")
            {
                Guid customerId = JsonSerializer.Deserialize<Guid>(customerMessage.Arguments);

                var movieIdList = _customerMessage.GetCustomerHistoryList(_config, customerId);
                response = new Message<List<HistoryItem>>("movies", "results", "ConstructHistoryList", movieIdList);

            }
            else if (customerMessage.FunctionToExecute == "UpdateCustomerInformation")
            {
                Customer customer = JsonSerializer.Deserialize<Customer>(customerMessage.Arguments);

                response = _customerMessage.UpdateCustomerInformation(_config, customer);
            }
            else if (customerMessage.FunctionToExecute == "CreateHistoryListItems")
            {
                CustomerMovieList billResultItems = JsonSerializer.Deserialize<CustomerMovieList>(customerMessage.Arguments);
                
                response = _customerMessage.AddHistoryListItems(_config, billResultItems);
            }

            return (customerMessage.PublishQueueName, JsonSerializer.Serialize(response));

        }
        

    }
}

/*
[HttpGet("{customer_id:Guid}")]
public async Task<List<string>> GetCustomer(Guid customer_id)
{

    foreach (var header in Request.Headers)
    {
        Console.WriteLine($"{header.Key}={header.Value}");
    }

    var customerList = new List<string>();

    string conn = _config.GetConnectionString("DefaultConnection");
    // NpgsqlDataReader myReader;
    using (NpgsqlConnection myCon = new NpgsqlConnection(conn))
    {
        myCon.Open();

        await using (var command = new NpgsqlCommand("SELECT * FROM customers WHERE id=@id", myCon))
        {
            command.Parameters.AddWithValue("id", customer_id);
            var reader = command.ExecuteReader();
            while (reader.Read())
            {
                customerList.Add(
                    string.Format(
                        "(id: {0}, name: {1}, email {2})",
                        reader.GetGuid(0).ToString(),
                        reader.GetString(1),
                        reader.GetString(2)
                        )
                    );
            }
            reader.Close();
        }
    }
    return customerList;
}

[HttpGet("customers")]
public async Task<List<string>> GetCustomersAsync(Guid customer_id)
{
    var customerList = new List<string>();
    string conn = _config.GetConnectionString("DefaultConnection");
   // NpgsqlDataReader myReader;
    using (NpgsqlConnection myCon = new NpgsqlConnection(conn))
    {
        myCon.Open();
        await using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM customers", myCon))
        {

            var reader = command.ExecuteReader();
            while (reader.Read())
            {
                customerList.Add(
                    string.Format(
                        "(id: {0}, name: {1}, email {2})",
                        reader.GetGuid(0).ToString(),
                        reader.GetString(1),
                        reader.GetString(2)
                        )
                    );
            }
            reader.Close();
        }
    }
    return customerList;
}
*/
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



