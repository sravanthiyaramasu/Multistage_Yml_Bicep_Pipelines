param storageAccountName string
param containerName string
param location string 
param topicName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}
var storageAccountId  = storageAccount.id

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
  properties: {}
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: containerName
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

// resource eventGridTopic 'Microsoft.EventGrid/topics@2021-12-01' = {
//   name: topicName
//   location: location
//   identity:{
// 	type:'SystemAssigned'
//   }  
//   properties: {
//     inputSchema: 'EventGridSchema'
//     source: storageAccount.id
//     topicType:'Microsoft.Storage.StorageAccounts'
//   }
// }

output storageAccountKey string = listKeys(storageAccount.id, '2022-09-01').keys[0].value
output storageAccountId string = storageAccount.id
// output eventGridTopicId string  = eventGridTopic.id
// output eventGridTopicEndpoint string = eventGridTopic.properties.endpoint
// output eventGridTopicKey string = listKeys(eventGridTopic.id, '2021-12-01').key1



