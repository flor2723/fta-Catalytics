param resourceName string
param 


resource _resourceName 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: resourceName
}

