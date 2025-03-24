using Azure.Storage.Blobs;
using Microsoft.ApplicationInsights;
using Microsoft.Extensions.DependencyInjection;


var builder = WebApplication.CreateBuilder(args);
// Add services to the container
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Application Insights telemetry
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration["ApplicationInsights:InstrumentationKey"]);

// Optionally configure logging to use Application Insights
builder.Logging.AddApplicationInsights(builder.Configuration["ApplicationInsights:InstrumentationKey"]);

// Retrieve Event Hub connection string from configuration
string eventHubConnectionString = builder.Configuration["EventHubs:ConnectionString"];

// Register EventHubListenerService and pass the connection string
builder.Services.AddSingleton(sp => new EventHubListenerService(		
	sp.GetRequiredService<ILogger<EventHubListenerService>>(),
	sp.GetRequiredService<TelemetryClient>(),
	new BlobServiceClient(builder.Configuration["AzureWebJobsStorage"])
));
builder.Services.AddHostedService<EventHubListenerService>();

// Register BlobServiceClient with the connection string from configuration
builder.Services.AddSingleton(new BlobServiceClient(builder.Configuration["AzureWebJobsStorage"]));

var app = builder.Build();


//Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
	app.UseSwagger();
	app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
