namespace SharedModelLibrary
{
    public class Bill
    {
        public int OrderId { get; set; }
        public Guid CustomerId { get; set; } 
        public int ProductTypeId { get; set; }
        public List<int> MovieIdList { get; set; }
        public double Price { get; set; }   
        public DateTime TimestampCreated { get; set; }
        public Boolean Status { get; set; }
        public DateTime TimestampUpdated { get; set; }

        public Bill(int orderId, Guid customerId, int productTypeId, List<int> movieIdList, double price, DateTime timestampCreated, bool status, DateTime timestampUpdated)
        {
            OrderId = orderId;
            CustomerId = customerId;
            ProductTypeId = productTypeId;
            MovieIdList = movieIdList;
            Price = price;
            TimestampCreated = timestampCreated;
            Status = status;
            TimestampUpdated = timestampUpdated;
        }
    }
}