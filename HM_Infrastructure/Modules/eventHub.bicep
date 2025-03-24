param location string 
param FuncAppName string
param ApiAppName string 
param applicationInsightsName string
param storageAccountName string
param hostingPlanName string
param eventHubNamespaceName string
param eventHubName string

// resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
//   name: appServicePlanName
//   location: location
//   sku: {
//     name: 'S1'
//     tier: 'Standard'
//   }
//   properties: {
//     reserved: true
//   }
// }
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: eventHubName
  parent: eventHubNamespace
  properties: {}
}
resource authRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'RootManageSharedAccessKey'
  parent: eventHubNamespace
  properties: {
    rights: [
      'Listen'
      'Send'
      'Manage'
    ]
  }
}

var eventHubConnectionString = listKeys('${eventHubNamespace.id}/authorizationRules/RootManageSharedAccessKey','2022-01-01-preview').primaryConnectionString

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' existing = {
 name: hostingPlanName
}
var hostingPlanId  = hostingPlan.id

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

var applicationInsightsInstrumentationKey = applicationInsights.properties.InstrumentationKey
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName  
}

resource apiApp 'Microsoft.Web/sites@2022-09-01' = {
  name: ApiAppName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2021-08-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'EventHubConnectionString'
          value: eventHubConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
      ]
    }
  }
  kind: 'api'
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: FuncAppName
} 


resource functionAppConfig 'Microsoft.Web/sites/config@2022-03-01'  = {
    parent: functionApp
    name: 'Web'  
  properties: {
    connectionStrings: [
    {
      name:'EventHubConnectionString'
      value: eventHubConnectionString
      type: 'Custom'
      slotSetting: true    
    }
	]
  }
}