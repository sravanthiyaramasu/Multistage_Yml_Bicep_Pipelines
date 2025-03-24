param functionAppName string
param topicEndpoint string
param topicKey string

resource functionAppExisting 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}
resource functionAppUpdateConnections 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionAppExisting
  name: 'connectionstrings'
  properties: {    
    EventGridTopicEndpoint: {
      value: topicEndpoint
      type: 'Custom'
      slotSetting: true
    }
    EventGridTopicKey: {
      value: topicKey
      type: 'Custom'
      slotSetting: true
    }
   
  }
}
resource functionAppSlotStagingExisting 'Microsoft.Web/sites/slots@2021-01-15' existing = {
  parent: functionAppExisting  
  name: 'staging'
}
resource functionAppSlotUpdateConnections 'Microsoft.Web/sites/slots/config@2022-09-01' = {
  parent: functionAppSlotStagingExisting
  name: 'connectionstrings'
  properties: {    
    EventGridTopicEndpoint: {
      value: topicEndpoint
      type: 'Custom'
      slotSetting: true
    }
    EventGridTopicKey: {
      value: topicKey
      type: 'Custom'
      slotSetting: true
    }
   
  }
}