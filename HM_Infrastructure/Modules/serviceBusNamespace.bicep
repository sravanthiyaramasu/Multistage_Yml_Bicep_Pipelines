param serviceBusNamespaceName string
param serviceBusQueueName string
param location string 

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {} 
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name:  serviceBusQueueName
  location: location
  properties: {
    lockDuration: 'PT5M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

// resource serviceBusQueueOut 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
//   parent: serviceBusNamespace
//   name:  '${serviceBusQueueName}-out'
//   location: location
//   properties: {
//     lockDuration: 'PT5M'
//     maxSizeInMegabytes: 1024
//     requiresDuplicateDetection: false
//     requiresSession: false
//     defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
//     deadLetteringOnMessageExpiration: false
//     duplicateDetectionHistoryTimeWindow: 'PT10M'
//     maxDeliveryCount: 10
//     autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
//     enablePartitioning: false
//     enableExpress: false
//   }
// }

// Resource: Authorization Rule
resource serviceBusAuthRule 'Microsoft.ServiceBus/namespaces/authorizationRules@2021-06-01-preview' = {
  parent: serviceBusNamespace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Send'
      'Manage'
    ]
  }
}

output serviceBusNamespaceId string = serviceBusNamespace.id
output serviceBusQueueId string = serviceBusQueue.id
output ConnectionString string = listKeys(serviceBusAuthRule.id, '2021-06-01-preview').primaryConnectionString
