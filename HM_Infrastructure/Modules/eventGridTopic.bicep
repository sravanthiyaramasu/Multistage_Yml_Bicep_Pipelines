param location string 
param FuncAppName string
param storageAccountName string
param topicName string
param eventHubNamespaceName string
param eventHubName string

resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: FuncAppName  
}
resource functionAppHost 'Microsoft.Web/sites/host@2022-03-01' existing = {
  name: 'default'
  parent: functionApp
}


output functionAppHostName string = functionApp.properties.defaultHostName
var defaultHostKey = functionAppHost.listKeys().functionKeys.default
var functionAppEndpoint = 'https://${functionApp.properties.defaultHostName}/api/BlobCreatedEventFunction?code=${defaultHostKey}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName  
}
resource eventGridTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' = {
  name: topicName
  location: location
  identity:{
	type:'SystemAssigned'
  }  
  properties: {
    inputSchema: 'EventGridSchema'
    source: storageAccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}
var eventGridTopicId  = eventGridTopic.id
var eventGridTopicEndpoint = eventGridTopic.properties.endpoint
var eventGridTopicKey  = listKeys(eventGridTopic.id, '2023-12-15-preview').key1



// resource storageAccountEventSubscription  'Microsoft.EventGrid/eventSubscriptions@2021-12-01' = {    
//    name:'StorageAccountEventsub'
//    scope: storageAccount
//    properties: {        
//         destination: {            
//             properties: {                
//                 endpointUrl:eventGridTopicEndpoint 
//                 sasKey: eventGridTopicKey
//             }
//             endpointType: 'EventGridTopic'
//         }
//         filter: {      
//            includedEventTypes: [
//              'Microsoft.Storage.BlobCreated'
//              'Microsoft.Storage.BlobDeleted'
//            ]
//         }
        
//         deadLetterDestination: {
//           endpointType: 'StorageBlob'
//           properties: {
//             resourceId: storageAccount.id
//             blobContainerName: 'deadletter'
//           }
//         }

//    }
// }
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview'  existing = {
  name: eventHubNamespaceName  
}
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview'  existing = {
  name: eventHubName
  parent: eventHubNamespace  
}
var eventHubId = eventHub.id

resource eventViewerSubscription  'Microsoft.EventGrid/systemTopics/eventSubscriptions@2023-12-15-preview' = {    
    parent: eventGridTopic
    name:'eventViewerSubscription'    
   properties: {        
        destination: {            
            properties: {                
                endpointUrl:'https://web-se-eventviewer-dev.azurewebsites.net/api/updates'               
            }
            endpointType: 'WebHook'
        }
     filter: {      
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
        'Microsoft.Storage.BlobDeleted'
      ]
     }
   }
}


resource gridToHubSubscription  'Microsoft.EventGrid/systemTopics/eventSubscriptions@2023-12-15-preview' = {     
    parent: eventGridTopic
    name:'gridToHubSubscription'    
   properties: {        
        destination: {   
            endpointType: 'EventHub'
            properties: {                
                resourceId: eventHub.id               
            }
            
        }
     filter: {      
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
        'Microsoft.Storage.BlobDeleted'
      ]
     }
   }
}