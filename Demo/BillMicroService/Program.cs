using Microsoft.AspNetCore.Builder;
using BillMicroService;
using System.Xml.Linq;
using BillMicroService.Models;
using BillMicroService.Services;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using BillMicroService.Controller;
using System.Xml.Linq;
using Microsoft.EntityFrameworkCore;


var builder = WebApplication.CreateBuilder(args);

string dbHost = Environment.GetEnvironmentVariable("DB_HOST");
string user = Environment.GetEnvironmentVariable("POSTGRES_USER");
string dbName = "BillDB";
string dbPassword = Environment.GetEnvironmentVariable("POSTGRES_PASSWORD");
string port = "5432";

builder.Services.AddDbContext<BillDBContext>(options => {
    options.UseSqlServer(builder.Configuration.GetConnectionString($"Server={dbHost};Username={user};Database={dbName};Port={5432};Password={dbPassword}"));
});


builder.Services.AddSingleton<IBillService, BillService>(); 
builder.Services.AddSingleton<BillController>();

builder.Services.AddHostedService<BillWorker>(sp =>
{
    var billController = sp.GetRequiredService<BillController>();

    return new BillWorker(billController, "bills");

});

builder.Services.AddControllers();

var app = builder.Build();
app.MapControllers();
app.RunAsync();


