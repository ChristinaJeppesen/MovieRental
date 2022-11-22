using System.Collections.Generic;
using MovieMicroService.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;

namespace MovieMicroService.Models
{
    public class MovieDBContext : DbContext
    {
        public MovieDBContext(DbContextOptions<MovieDBContext> options) : base(options)
        {

        }
        public DbSet<Models.Movie> Movies { get; set; }

    }
}
