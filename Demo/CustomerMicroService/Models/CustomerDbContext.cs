using CustomerMicroService.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;

namespace CustomerMicroService
{

    public class CustomerDbContext : DbContext
    {

        public CustomerDbContext(DbContextOptions<CustomerDbContext> options) : base(options)
        {

        }

      
        public DbSet<Models.Customer> Customers { get; set; }

    }
}