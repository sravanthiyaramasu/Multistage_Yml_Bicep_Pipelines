using Azure.Storage.Blobs;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using System.Configuration;

public class EventHubListenerService : BackgroundService
{
	private readonly ILogger<EventHubListenerService> _logger;
	private readonly BlobServiceClient _blobServiceClient;
	private readonly string _containerName = ""; // Name of the blob container
	private readonly string _eventHubConnectionString= "EventHubConnectionString";
	private readonly string _eventHubName = "evnthubName";
	private readonly string _consumerGroup = "$Default";
	private EventHubConsumerClient _consumerClient;
	private readonly TelemetryClient _telemetryClient;	

	public EventHubListenerService(		
		ILogger<EventHubListenerService> logger,
		TelemetryClient telemetryClient,
		BlobServiceClient blobServiceClient)
	{		
		_consumerClient = new EventHubConsumerClient(EventHubConsumerClient.DefaultConsumerGroupName, _eventHubConnectionString);
		_logger = logger;
		_telemetryClient = telemetryClient;
		_blobServiceClient = blobServiceClient;

	} 

	protected override async Task ExecuteAsync(CancellationToken stoppingToken)
	{
		await foreach (PartitionEvent partitionEvent in _consumerClient.ReadEventsAsync(stoppingToken))
		{
			string message = Encoding.UTF8.GetString(partitionEvent.Data.Body.ToArray());
			_logger.LogInformation("Received event: {Message}", message);

			// Save the event message to Blob Storage
			await SaveMessageToBlobStorageAsync(message, stoppingToken);
		}
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
