using System.Xml.Linq;
using MessageService;
using MessageService.Controller;
using MessageService.Service;


var builder = WebApplication.CreateBuilder(args);



builder.Services.AddEndpointsApiExplorer();
//builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<IMessageService, Service>();

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

