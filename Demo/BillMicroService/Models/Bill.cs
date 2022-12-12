namespace BillMicroService.Models
{
    public class Bill
    {
        public int OrderId { get; set; }
        public int ProductTypeId { get; set; }
        public double Price { get; set; }   
        public DateTime Timestamp { get; set; }


    }
}