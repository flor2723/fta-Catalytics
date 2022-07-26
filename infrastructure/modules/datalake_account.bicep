param name string
param location string
param tags object

// Storage Account
resource datalake 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
 
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
      
    }
    supportsHttpsTrafficOnly: true
    isHnsEnabled: true
  }

  tags: tags
}

output sdatalakeOut string = datalake.id
