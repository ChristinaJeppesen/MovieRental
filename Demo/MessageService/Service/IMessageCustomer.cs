using System;
namespace MessageService.Service
{
    public interface IMessageCustomer
    {
        public void GetAllCustomers();

        public string GetResults();
    }
}

