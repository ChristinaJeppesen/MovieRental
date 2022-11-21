﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CustomerWebApi.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using CustomerWebApi.Service;
using Npgsql;
using System.Text.Json;

namespace CustomerWebApi.Controllers
{
    [Route("[controller]")]
    [Controller]
    public class CustomerController : ControllerBase
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


        public List<Customer> MessageReceived(string inMessage)
        {
            Console.WriteLine(" - Message Recieved");
            var list = new List<Customer>();

            CustomerMessage? customerMessage = JsonSerializer.Deserialize<CustomerMessage>(inMessage);

            if (customerMessage.FunctionToExecute == "GetAllCustomers")
            {
                Console.WriteLine("Getting all customers....");
                list = _customerMessage.GetAllCustomers(_config);
            }

            else if (customerMessage.FunctionToExecute == "GetCustomer")
            {
                list.Add(_customerMessage.GetCustomer(_config));
            }

            return list;

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



