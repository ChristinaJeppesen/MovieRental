using Npgsql;
//using BillMicroService.Models;
using SharedModelLibrary;

namespace BillMicroService.Services
{
    public class BillService : IBillService
    {

        public List<Bill> GetCustomerBillList(IConfiguration config)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - GetCustomerBillList() enabled");
            var billList = new List<Bill>();

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                using (var command = new NpgsqlCommand("SELECT * " +
                                                       "FROM bill ", conn))
                {
                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        Bill bill = new()
                        {
                            OrderId = reader.GetInt32(0),
                            ProductTypeId = reader.GetInt32(1),
                            Price = reader.GetDouble(2),
                            Timestamp = reader.GetDateTime(3)
                        };
                        billList.Add(bill);
                    };
                    reader.Close();
                    Console.Out.WriteLine("   - Connection closed");
                }
            }
            Console.WriteLine(billList);
            return billList;
        }
        public int CreateBill(IConfiguration config, Bill arguments)
        {
            string connString = config.GetConnectionString("DefaultConnection");

            Console.Out.WriteLine(" - CreateBill() enabled");
            int orderCreated = -1;

            using (var conn = new NpgsqlConnection(connString))
            {
                Console.Out.WriteLine("   - Opening connection");
                conn.Open();

                using (var command = new NpgsqlCommand("INSERT INTO bill (product_type_id, price, timestamp) VALUES (@t0, @t1, @t2)", conn))
                {

                    command.Parameters.AddWithValue("t0", arguments.ProductTypeId);
                    command.Parameters.AddWithValue("t1", arguments.Price);
                    command.Parameters.AddWithValue("t2", DateTime.Now);

                    orderCreated = command.ExecuteNonQuery();
                }
                Console.Out.WriteLine("   - Closing connection");
                conn.Close();
            }
            return orderCreated;
        }
    

        public int UpdatePayment(IConfiguration config)
        {
            throw new NotImplementedException();
        }

        List<Bill> IBillService.UpdatePayment(IConfiguration config)
        {
            throw new NotImplementedException();
        }
    }
}
