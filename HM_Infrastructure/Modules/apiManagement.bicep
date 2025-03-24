// Define parameters
param location string
param apimName string 
param functionAppName string
param functionAppResourceId string
param skuName string = 'Developer' // SKU options: Developer, Basic, Standard, Premium
param publisherEmail string = 'publisherEmail'
param publisherName string = 'publisherName'
param clientId string = 'clientId'
param clientSecret string = 'clientSecret'

@minLength(6)
@maxLength(50)
param apimAdminUsername string = 'apimAdminUsername'
@secure()
param apimAdminPassword string = 'apimAdminPassword'

// Define the API Management service
resource apiManagement 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimName
  location: location
  sku: {
    name: skuName
    capacity: 1
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    notificationSenderEmail: 'notificationSenderEmail'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource apiVersionSet 'Microsoft.ApiManagement/service/apiVersionSets@2021-08-01' = {
  name: 'myApiVersionSet'
  parent: apiManagement
  properties: {
    displayName: 'My API Version Set'
    versioningScheme: 'Segment'  // Options: 'Segment', 'Query', 'Header'
    versionQueryName: 'api-version'  // Required if using 'Query' scheme
    versionHeaderName: 'api-version'  // Required if using 'Header' scheme
  }
}

resource oauth2 'Microsoft.ApiManagement/service/authorizationServers@2021-08-01' = {
  name: 'myOAuth2'
  parent: apiManagement
  properties: {
    clientId: clientId
    clientSecret: clientSecret
    authorizationEndpoint: 'authorizationEndpoint'
    tokenEndpoint: 'tokenEndpoint'
    clientRegistrationEndpoint: 'https://localhost' // Placeholder, replace with actual URL or a valid URL
    grantTypes: ['authorizationCode']
    displayName: 'My OAuth2 Server'
    defaultScope: 'defaultScope'
    bearerTokenSendingMethods: ['authorizationHeader']
    authorizationMethods: ['GET','POST'] // Specify the allowed authorization methods
  }
}



resource product 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: 'funcAppProduct'
  parent: apiManagement
  properties: {
    displayName: 'funcAppProduct'
    description: 'Product for func app API'
    subscriptionRequired: true    
    //state: productPublished ? 'published' : 'notPublished'
  }
}

resource functionAppApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: functionAppName
  parent: apiManagement
  properties: {
    displayName: 'Function app API'
    serviceUrl: 'https://${functionAppName}.azurewebsites.net'
    path: 'api'
    protocols: ['https']
  }
}
// Associating an API with a Product
resource apiToProduct 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: functionAppApi.name
  parent: product
  properties: {}
}

// Outputs
output apiManagementName string = apiManagement.name
//output apiUrl string = sampleApi.properties.serviceUrl


resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: 'policy'
  parent: functionAppApi
  properties: {
    policyContent: '''
    <policies>
      <inbound>
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401" require-scheme="Bearer">
            <openid-config url="https://login.microsoftonline.com/5845c03f-fab4-45d5-9d5c-e05c96103e19/v2.0/.well-known/openid-configuration" />
            <issuers>
                <issuer>https://sts.windows.net/5845c03f-fab4-45d5-9d5c-e05c96103e19/</issuer>
            </issuers>
            <required-claims>
                <claim name="aud">
                    <value>api://0d9c8d31-fd17-4bd6-a879-d164282de5d9</value>
                </claim>
            </required-claims>
        </validate-jwt>
        <base />        
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
    </policies> 
  '''
  }
}
// Define a  API
//Subscription Keys
// resource functionAppApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
//   parent: apiManagement
//   name: functionAppName
//   properties: {
//     displayName: 'Function app API'
//     serviceUrl: 'https://${functionAppName}.azurewebsites.net'
//     path: 'api'
//     protocols: [
//       'https'
//     ]
//     apiRevision: '1'
//     apiVersion: 'v1'
//     isCurrent: true
//     subscriptionRequired: true  // Enables subscription key requirement
//     apiVersionSetId: apiVersionSet.id
//   }
// }

// Import HTTP-triggered function as an API operation
// resource functionApiOperation 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
//   parent: functionAppApi
//   name: 'functions'
//   properties: {
//     displayName: 'Post Function'
//     method: 'Post'
//     urlTemplate: '/my-function'
//     request: {}
//     responses: [
//       {
//         statusCode: 200
//         description: 'OK'
//         representations: [
//           {
//             contentType: 'application/json'
//           }
//         ]
//       }
//     ]
//   }
// }
//test2
