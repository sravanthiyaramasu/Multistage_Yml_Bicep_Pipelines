using Azure.Messaging.EventHubs.Consumer;
using Azure.Storage.Blobs;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using System.Text;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace EventHubApi.Controller
{

	[Route("api/[controller]")]
	[ApiController]
	public class eventHubController : ControllerBase
	{
		private readonly ILogger<EventHubListenerService> _logger;
		private readonly BlobServiceClient _blobServiceClient;
		private readonly string _containerName = "apiappcontainer"; // Name of the blob container
		private readonly string _eventHubConnectionString = "Endpoint=sb://ns-logicapptohub-dev.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=6RtmUyiGUOUWaUFeMQP5MMmmwjLn37eJI+AEhK+GGew=;EntityPath=evnthubtola";
		private readonly string _eventHubName = "evnthubtola";
		private readonly string _consumerGroup = "$Default";
		private EventHubConsumerClient _consumerClient;
		private readonly TelemetryClient _telemetryClient;

		public eventHubController(ILogger<EventHubListenerService> logger, BlobServiceClient blobServiceClient, TelemetryClient telemetryClient)
		{
			_logger = logger;
			_blobServiceClient = blobServiceClient;
			_consumerClient = new EventHubConsumerClient(_consumerGroup, _eventHubConnectionString, _eventHubName);
			_telemetryClient = telemetryClient;
		}

		// GET: api/<eventHubController>
		[HttpGet]
		public async Task<IEnumerable<string>> Get()
		{
			string message = "";
			CancellationToken stoppingToken= new CancellationToken();
			await foreach (PartitionEvent partitionEvent in _consumerClient.ReadEventsAsync(stoppingToken))
			{
				 message = Encoding.UTF8.GetString(partitionEvent.Data.Body.ToArray());
				_logger.LogInformation("Received event: {Message}", message);

				// Save the event message to Blob Storage
				await SaveMessageToBlobStorageAsync(message, stoppingToken);
				return new string[] { message };
			}
			return new string[] { message };

		}
		private async Task SaveMessageToBlobStorageAsync(string message, CancellationToken cancellationToken)
		{
			var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);

			// Create the container if it does not exist
			await containerClient.CreateIfNotExistsAsync(cancellationToken: cancellationToken);

			// Generate a unique filename for the blob
			string blobName = $"event-{DateTime.UtcNow:yyyyMMdd-HHmmss}-{Guid.NewGuid()}.txt";
			var blobClient = containerClient.GetBlobClient(blobName);

			// Upload the message to the blob
			using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(message)))
			{
				await blobClient.UploadAsync(stream, cancellationToken);
			}

			_logger.LogInformation("Event saved to blob storage with name: {BlobName}", blobName);
		}


	}
}
