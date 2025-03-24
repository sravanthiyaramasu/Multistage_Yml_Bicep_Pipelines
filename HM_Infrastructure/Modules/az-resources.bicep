@description('Name of the Func App Name')
param FuncAppName string 

@description('Name of the Env')
param Env string 

@description('Location for all resources.')
param Location string = resourceGroup().location

@description('Name of the App')
param App string

@description('Name of the AppType')
param AppType string

@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Service Bus queue')
param serviceBusQueueName string

@description('Name of the Service Bus queue')
param storageAccountName string

@description('Name of the Service Bus queue')
param containerName string

@description('Name of the hosting plan')
param hostingPlanName  string

@description('Name of the application insights')
param applicationInsightsName  string

@description('Name of the function Worker Runtime ')
param functionWorkerRuntime   string = 'dotnet'

@description('The name of the Key Vault.')
param keyVaultName string

@description('The name of the Managed identity.')
param managedIdentityName string

@description('The name of the keyVaultResourceGroup .')
param keyVaultResourceGroup  string

@description('The name of the functionAppSlotName.')
param functionAppSlotName string = 'staging' // or other slot names like 'lastknown'

@description('The name of the topicName.')
param topicName string 

@description('The name of the apiManagement.')
param apimName string 



module serviceBusNamespace './serviceBusNamespace.bicep' = {
  name: 'serviceBusNamespaceDeployment'
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    serviceBusQueueName : serviceBusQueueName
    location:Location   
  }
}
var sBConnectionString = serviceBusNamespace.outputs.ConnectionString

module storageAccount './storageAccount.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    storageAccountName: storageAccountName
    containerName: containerName
    location:Location
    topicName:topicName
  }
}
var storageAccountKey = storageAccount.outputs.storageAccountKey
var storageAccountId = storageAccount.outputs.storageAccountId
// var eventGridTopicId  = storageAccount.outputs.eventGridTopicId
// var eventGridTopicEndpoint = storageAccount.outputs.eventGridTopicEndpoint
// var eventGridTopicKey  = storageAccount.outputs.eventGridTopicKey
 

// resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: managedIdentityName
//   location: Location
//   properties: {}
// }

module hostingPlan './hostingPlan.bicep' = {
  name: 'hostingPlanDeployment'
  params: {
    hostingPlanName: hostingPlanName
    location: Location
  }
}
var hostingPlanId = hostingPlan.outputs.hostingPlanId

module applicationInsights './applicationInsights.bicep' = {
  name: 'applicationInsightsDeployment'  
  params: {
    applicationInsightsName: applicationInsightsName
    location: Location
  }
  dependsOn: [
    hostingPlan
  ]
}
var applicationInsightsInstrumentationKey = applicationInsights.outputs.applicationInsightsInstrumentationKey

// Module for setting the secret in the Key Vault located in a different resource group
// module setSecretModule 'setSecret.bicep' = {
//   name: 'setSecretModule'
//   scope: resourceGroup(keyVaultResourceGroup)
//   params: {
//     keyVaultName: keyVaultName
//     sBConnectionString: sBConnectionString
//   }
// }


module functionApp './functionApp.bicep' ={
    name : 'functionAppDeployment'    
    params: {
    FuncAppName: FuncAppName
    location: Location
    hostingPlanId : hostingPlanId
    applicationInsightsInstrumentationKey : applicationInsightsInstrumentationKey
    storageAccountName : storageAccountName
    functionWorkerRuntime : functionWorkerRuntime
    managedIdentityName : managedIdentityName
    storageAccountKey : storageAccountKey
    serviceBusConnectionString : sBConnectionString      
    }
    dependsOn: [
    storageAccount
    serviceBusNamespace
  ]
}
var functionAppName = functionApp.outputs.functionAppName
var functionAppResourceId = functionApp.outputs.functionAppResourceId

module apiManagement './apiManagement.bicep' = {
  name: 'apiManagementDeployment'
  params: {
      location: Location
      apimName: apimName
      functionAppName : functionAppName
      functionAppResourceId : functionAppResourceId
  }
}


//output functionAppEndpoint string = functionApp.outputs.functionAppEndpoint

// Event Grid Topic
// module eventGridTopic './eventGridTopic.bicep' = {
//   name: 'eventGridTopicDeployment'
//   params: {
//     location: Location
//     topicName: topicName
//     storageAccountId : storageAccountId    
//     functionAppEndpoint : functionApp.outputs.functionAppEndpoint
//     storageAccountName : storageAccountName
//     //resourceGroupName : resourceGroup().name
//     // subscriptionName: eventGridSubscriptionName    
//     // funcEndpointUrl: '${functionBaseUrl}${webhookFunctionPath}'
//     // functionKey: functionCode
//   }
// }
// var topicEndpoint = eventGridTopic.outputs.topicEndpoint
// var topicKey =eventGridTopic.outputs.topicKey

// module UpdateFunctionAppSettings './UpdateFunctionAppSettings.bicep' = {
//   name: 'UpdateFunctionAppSettingsDeployment'
//   params: {
//     functionAppName: FuncAppName
//     topicEndpoint: topicEndpoint
//     topicKey : topicKey    
    
//   }
// }




