param name string
param location string
param tags object
param objectID string
param synapseManageIdentity string
@secure()
param ehnsconnstring string


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
      {
        objectId: synapseManageIdentity
        permissions: {          
          secrets: [
            'get'
            'list'
          ]          
        }
        tenantId: subscription().tenantId
      }
    ]
    
  }
  resource secret 'secrets' = {
    name: 'eh-conn-str'
    properties: {
      value: ehnsconnstring
    }
  }
  tags: tags
}

output kvOut string = kv.id
