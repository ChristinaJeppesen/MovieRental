//using BillMicroService.Models;
using SharedModelLibrary;

namespace BillMicroService.Services
{
    public interface IBillService
    {
        List<Bill> GetCustomerBillList(IConfiguration config, Guid customerId);
        int CreateBill(IConfiguration config, Bill bill);
        int UpdateCustomerBill(IConfiguration config, Bill bill);
    }
}
