using Npgsql;
//using BillMicroService.Models;
using SharedModelLibrary;
using System.Data;

namespace BillMicroService.Services
{
    public class BillService : IBillService
    {

        public List<Bill> GetCustomerBillList(IConfiguration config, Guid customerId)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - GetCustomerBillList() enabled");
            var billList = new List<Bill>();

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                var query = $"SELECT order_id, customer_id, product_type_id, movie_id_list, price, timestamp_created, status, timestamp_updated FROM bill WHERE customer_id='{customerId}' ORDER BY timestamp_created DESC";

                using (var command = new NpgsqlCommand(query, conn))
                {
                        
                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        List<int> list = reader.GetFieldValue<List<int>>(3);
                        Bill bill = new(reader.GetInt32(0), reader.GetGuid(1), reader.GetInt32(2), list, reader.GetDouble(4), reader.GetDateTime(5), reader.GetBoolean(6), reader.GetDateTime(7));

       
                        billList.Add(bill);
                    };
                    reader.Close();
                    Console.Out.WriteLine("   - Connection closed");
                }
            }
            Console.WriteLine(billList);
            return billList;
        }
        public int CreateBill(IConfiguration config, Bill bill)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - CreateBill() enabled");
            int orderCreated = -1;

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                
                var query = $"INSERT INTO bill (customer_id, movie_id_list, product_type_id, price, timestamp_created, timestamp_updated) " +
                            $"SELECT @t0 as customer_id, @t2 as movie_id_list, pr.product_type_id, price*@t3, NOW() as timestamp_created, NOW() as timestamp_updated " +
                            $"FROM( SELECT product_type_id, price FROM product_type WHERE product_type_id = @t1) as pr";

                using (var command = new NpgsqlCommand(query, conn))
                {

                    command.Parameters.AddWithValue("t0", bill.CustomerId);
                    command.Parameters.AddWithValue("t1", bill.ProductTypeId);
                    command.Parameters.AddWithValue("t2", bill.MovieIdList);
                    command.Parameters.AddWithValue("t3", bill.MovieIdList.Count);

                    orderCreated = command.ExecuteNonQuery();
                }
                Console.Out.WriteLine("   - Closing connection");
                conn.Close();
            }
            return orderCreated;
        }

        public int UpdateCustomerBill(IConfiguration config, Bill bill)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - CreateBill() enabled");
            int billUpdated = -1;

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();


                var query = $"UPDATE bill SET status = @t1, timestamp_updated = NOW() WHERE order_id = @t0";

                using (var command = new NpgsqlCommand(query, conn))
                {

                    command.Parameters.AddWithValue("t0", bill.OrderId);
                    command.Parameters.AddWithValue("t1", bill.Status);

                    billUpdated = command.ExecuteNonQuery();
                }
                Console.Out.WriteLine("   - Closing connection");
                conn.Close();
            }
            return billUpdated;
        }
    }
}
