using BillMicroService.Models;

namespace BillMicroService.Services
{
    public interface IBillService
    {
        int CreateBill(IConfiguration config, Bill arguments);
        List<Bill> GetCustomerBillList(IConfiguration config);
        List<Bill> UpdatePayment(IConfiguration config);
    }
}
