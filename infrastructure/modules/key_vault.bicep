param name string
param location string
param tags object
param objectID string

// Key Vault
resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: [
      {
        objectId: objectID
        permissions: {          
          secrets: [
            'all'
          ]          
        }
        tenantId: subscription().tenantId
      }
    ]
  }

  tags: tags
}

output kvOut string = kv.id
