param functionAppName string

resource functionAppExisting 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}

resource functionAppHost 'Microsoft.Web/sites/host@2022-03-01' existing = {
  name: 'default'
  parent: functionAppExisting
}

// Default host key
output defaultHostKey string = functionAppHost.listKeys().functionKeys.default

// Master key
output masterKey string = functionAppHost.listKeys().masterKey

// Addtionally grab the system keys
output systemKeys object = functionAppHost.listKeys().systemKeys