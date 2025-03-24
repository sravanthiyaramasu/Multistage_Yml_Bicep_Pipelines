param FuncAppName string
param location string 
param hostingPlanId string
param applicationInsightsInstrumentationKey string
param storageAccountName string
param functionWorkerRuntime string
param managedIdentityName string
param storageAccountKey string
param serviceBusConnectionString string


var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountKey}'

// resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: managedIdentityName
//   location: location
//   properties: {}
// }


resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: FuncAppName
  location: location
  kind: 'functionapp'
  // identity: {
  //   type: 'UserAssigned' 
  //   identityIds: [
  //     userAssignedIdentity.id
  //   ]
  // }
  identity: {
    type: 'SystemAssigned'
  }  
  properties: {
    serverFarmId: hostingPlanId
    siteConfig: {
      appSettings: [ 
        {
          name: 'serviceBusConnectionString'
          value: serviceBusConnectionString 
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageConnectionString
        }        
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsInstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }     
        
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

output functionAppName string = functionApp.name
output functionAppResourceId string = functionApp.id

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

// resource functionAppSlotStaging 'Microsoft.Web/sites/slots@2021-01-15' = {
//   parent: functionApp
//   name: 'staging'
//   location: location 
//   kind: 'functionapp'
//   // identity: {
//   //   type: 'UserAssigned'
//   //   identityIds: [
//   //     userAssignedIdentity.id
//   //   ]
//   // }
//    identity: {
//     type: 'SystemAssigned'
//   } 
//   properties: {
//     serverFarmId: hostingPlanId
//     siteConfig: {
//       appSettings: [
//         {
//           name: 'serviceBusConnectionString'
//           value: serviceBusConnectionString
//         }
//         {
//           name: 'AzureWebJobsStorage'
//           value: storageConnectionString
//         }
//         {
//           name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
//           value: storageConnectionString
//         }                
//         {
//           name: 'FUNCTIONS_EXTENSION_VERSION'
//           value: '~4'
//         }
//         {
//           name: 'WEBSITE_NODE_DEFAULT_VERSION'
//           value: '~14'
//         }
//         {
//           name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
//           value: applicationInsightsInstrumentationKey
//         }
//         {
//           name: 'FUNCTIONS_WORKER_RUNTIME'
//           value: functionWorkerRuntime
//         }
//         {
//           name: 'WEBSITE_RUN_FROM_PACKAGE'
//           value: '1'
//         }        
        
//       ]
//       ftpsState: 'FtpsOnly'
//       minTlsVersion: '1.2'
//     }
//     httpsOnly: true
//     dependsOn: [
//     functionApp
//     ]
//   }
// }

// resource functionAppSlotConnections 'Microsoft.Web/sites/slots/config@2022-09-01' = {
//   parent : functionAppSlotStaging
//   name: 'connectionstrings'
//   properties: {
//     AzureWebJobsStorage: {
//       value: storageConnectionString
//       type: 'Custom'
//       slotSetting: true
//     }
//     ServiceBusConnectionString: {
//       value: serviceBusConnectionString
//       type: 'Custom'
//       slotSetting: true
//     }
    
    
//   }    
// }

// resource functionAppSlotLastKnown 'Microsoft.Web/sites/slots@2021-01-15' = {
//   parent: functionApp
//   name: 'lastKnown'
//   location: location
//   kind: 'functionapp'
//   // identity: {
//   //   type: 'UserAssigned'
//   //   identityIds: [
//   //     userAssignedIdentity.id
//   //   ]
//   // }
//    identity: {
//     type: 'SystemAssigned'
//   } 
//   properties: {
//     serverFarmId: hostingPlanId
//     siteConfig: {
//        appSettings: [
//         {
//           name: 'serviceBusConnectionString'
//           value: serviceBusConnectionString
//         }
//          {
//           name: 'AzureWebJobsStorage'
//           value: storageConnectionString
//         }
//         {
//           name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
//           value: storageConnectionString
//         }                  
//         {
//           name: 'FUNCTIONS_EXTENSION_VERSION'
//           value: '~4'
//         }
//         {
//           name: 'WEBSITE_NODE_DEFAULT_VERSION'
//           value: '~14'
//         }
//         {
//           name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
//           value: applicationInsightsInstrumentationKey
//         }
//         {
//           name: 'FUNCTIONS_WORKER_RUNTIME'
//           value: functionWorkerRuntime
//         }
//         {
//           name: 'WEBSITE_RUN_FROM_PACKAGE'
//           value: '1'
//         }
               
//        ]
//       ftpsState: 'FtpsOnly'
//       minTlsVersion: '1.2'
//     }
//     httpsOnly: true
//     dependsOn: [
//       functionApp
//     ]
//   }
// }
// output defaultHostKey string = functionAppHost.listKeys().functionKeys.default
// output functionAppEndpoint string = 'https://${functionApp.properties.defaultHostName}/api/BlobCreatedEventFunction?code=${defaultHostKey}'

