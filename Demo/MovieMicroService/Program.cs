using Microsoft.AspNetCore.Builder;
using MovieMicroService;
using System.Xml.Linq;
using MovieMicroService.Models;
using MovieMicroService.Services;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using MovieMicroService.Controller;
using System.Xml.Linq;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

string dbHost = Environment.GetEnvironmentVariable("DB_HOST");
string user = Environment.GetEnvironmentVariable("POSTGRES_USER");
string dbName = "MovieDB";
string dbPassword = Environment.GetEnvironmentVariable("POSTGRES_PASSWORD");
string port = "5432";

builder.Services.AddDbContext<MovieDBContext>(options => {
    options.UseSqlServer(builder.Configuration.GetConnectionString($"Server={dbHost};Username={user};Database={dbName};Port={5432};Password={dbPassword}"));
});


builder.Services.AddSingleton<IMovieService, MovieService>(); 
builder.Services.AddSingleton<MovieController>();
builder.Services.AddHostedService<MovieWorker>(sp =>
{
    var customerController = sp.GetRequiredService<MovieController>();

    return new MovieWorker(customerController, "movies");

});

builder.Services.AddControllers();

var app = builder.Build();
app.MapControllers();
app.RunAsync();


