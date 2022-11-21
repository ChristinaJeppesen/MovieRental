using System.Xml.Linq;
using CustomerWebApi;
using Microsoft.EntityFrameworkCore;
using CustomerWebApi.Service;
using CustomerWebApi.Controllers;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

string dbHost = Environment.GetEnvironmentVariable("DB_HOST");
string user = Environment.GetEnvironmentVariable("POSTGRES_USER");
string dbName = "customers";
string dbPassword = Environment.GetEnvironmentVariable("POSTGRES_PASSWORD");
string port = "5432";

builder.Services.AddDbContext<CustomerDbContext>(options => {
    options.UseSqlServer(builder.Configuration.GetConnectionString($"Server={dbHost};Username={user};Database={dbName};Port={5432};Password={dbPassword}"));
});
builder.Services.AddControllers();

builder.Services.AddSingleton<ICustomerMessage, CustomerService>(); // once per request
builder.Services.AddSingleton<CustomerController>();
builder.Services.AddHostedService<Worker>();

var app = builder.Build();


app.UseAuthorization();

app.MapControllers();

app.Run();

