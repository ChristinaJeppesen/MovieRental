using CustomerMicroService.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;
using SharedModelLibrary;

namespace CustomerMicroService
{

    public class CustomerDbContext : DbContext
    {

        public CustomerDbContext(DbContextOptions<CustomerDbContext> options) : base(options)
        {

        }

      
        public DbSet<Customer> Customers { get; set; }

    }
}