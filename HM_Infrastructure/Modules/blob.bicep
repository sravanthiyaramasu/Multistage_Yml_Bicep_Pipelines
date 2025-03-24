param storageAccountName string
param containerName string

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
  properties: {}
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: containerName
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

output blobServiceId string = blobService.id
output blobContainerId string = blobContainer.id
output containerName string = blobContainer.name