param keyVaultName string
param sBConnectionString string

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource serviceBusConnectionStringKv 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'ServiceBusConnectionString'
  properties: {
    value: sBConnectionString
  }
}

