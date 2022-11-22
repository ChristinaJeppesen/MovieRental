using System.Xml.Linq;
using MessageMicroService;
using MessageMicroService.Controller;
using MessageMicroService.Services;


var builder = WebApplication.CreateBuilder(args);



builder.Services.AddEndpointsApiExplorer();
//builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<IMessageService, MessageService>();
//builder.Services.AddSingleton<IMessageCustomer, CustomerService>();

builder.Services.AddControllers();



var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseAuthorization();

app.MapControllers();

app.Run();

