using System.Xml.Linq;
using CustomerMicroService;
using Microsoft.EntityFrameworkCore;
using CustomerMicroService.Services;
using CustomerMicroService.Controllers;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

string dbHost = Environment.GetEnvironmentVariable("DB_HOST");
string user = Environment.GetEnvironmentVariable("POSTGRES_USER");
string dbName = "CustomerDB";
string dbPassword = Environment.GetEnvironmentVariable("POSTGRES_PASSWORD");
string port = "5432";

builder.Services.AddDbContext<CustomerDbContext>(options => {
    options.UseSqlServer(builder.Configuration.GetConnectionString($"Server={dbHost};Username={user};Database={dbName};Port={5432};Password={dbPassword}"));
});
builder.Services.AddControllers();
builder.Services.AddSingleton<ICustomerMessage, CustomerService>(); 
builder.Services.AddSingleton<CustomerController>();
builder.Services.AddHostedService<CustomerWorker>(sp =>
{
    var customerController = sp.GetRequiredService<CustomerController>();

    return new CustomerWorker(customerController, "customers");

});

var app = builder.Build();


app.UseAuthorization();

app.MapControllers();

app.Run();

