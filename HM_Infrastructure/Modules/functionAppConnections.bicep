@description('Name of the Func App Name')
param FuncAppName string
param functionAppSlotName string
param storageConnectionString string

param serviceBusConnectionString string

resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: FuncAppName
}

resource functionAppConnections 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionApp
  name: 'connectionstrings'
  properties: {
    AzureWebJobsStorage: {
      value: storageConnectionString
      type: 'Custom'
      slotSetting: true
    }
    ServiceBusConnectionString: {
      value: serviceBusConnectionString
      type: 'Custom'
      slotSetting: true
    }
  }
}

resource functionAppSlot 'Microsoft.Web/sites/slots@2022-09-01' existing = {
  parent: resourceId('Microsoft.Web/sites', FuncAppName)
  name: functionAppSlotName
}

resource functionAppSlotConnections 'Microsoft.Web/sites/slots/config@2022-09-01' = {
  parent: functionAppSlotStaging
  name: 'connectionstrings'
  properties: {
    AzureWebJobsStorage: {
      value: storageConnectionString
      type: 'Custom'
      slotSetting: true
    }
    ServiceBusConnectionString: {
      value: serviceBusConnectionString
      type: 'Custom'
      slotSetting: true
    }
  }
}

output functionAppConnectionStringsId string = functionAppConnections.id
output functionAppSlotConnectionStringsId string = functionAppSlotConnections.id