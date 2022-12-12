using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;
using SharedModelLibrary;

namespace BillMicroService.Models
{
    public class BillDBContext : DbContext
    {
        public BillDBContext(DbContextOptions<BillDBContext> options) : base(options)
        {

        }
        public DbSet<SharedModelLibrary.Bill> Bills { get; set; }

    }
}
