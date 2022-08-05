param synapseName string
param location string
param tags object
param administratorLogin string
@secure()
param administratorLoginPassword string


param datalakegen2name string
param defaultDataLakeStorageFilesystemName string
param dataLakeUrlFormat  string
param sparkPoolName string
param sparkPollNodeSize string
param sparkPoolMinNodeCount int
param sparkPoolMaxNodeCount int




var storageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageRoleUniqueId = guid(resourceId('Microsoft.Storage/storageAccounts', synapseName), datalakegen2name)
//var storageRoleUserUniqueId = guid(resourceId('Microsoft.Storage/storageAccounts', synapseName), userObjectId)


// creating the storage.
resource datalakegen2 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: datalakegen2name
  kind: 'StorageV2'
  location: location
  properties:{
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true
  }
  sku: {
    name: 'Standard_LRS'
  }
}


// enabling the blob service
resource blob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name:  '${datalakegen2.name}/default'
}

// creating the container
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${datalakegen2.name}/default/${defaultDataLakeStorageFilesystemName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn:[
    blob
  ]
} 

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: location
  properties: {
    sqlAdministratorLogin: administratorLogin
    sqlAdministratorLoginPassword: administratorLoginPassword
    defaultDataLakeStorage:{
      accountUrl: format(dataLakeUrlFormat, datalakegen2.name)
      filesystem: defaultDataLakeStorageFilesystemName
    }
  }
  identity:{
    type:'SystemAssigned'
  }
  resource firewall 'firewallRules' = {
    name: 'allowAll'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }
  tags: tags
}
output synapsemanageidentity string = synapse.identity.principalId

// giving storage blob data contributor access to adls gen2 for the synapse manage identity.
resource synapseroleassing 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: storageRoleUniqueId
  scope: datalakegen2
  properties:{
    principalId: synapse.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleID)
  }
}

//creating the spark pool

resource sparkpool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  name: sparkPoolName
  location: location
  parent: synapse
  properties:{
    nodeSize: sparkPollNodeSize
    nodeSizeFamily: 'MemoryOptimized'
    autoScale:{
      enabled: true
      minNodeCount: sparkPoolMinNodeCount
      maxNodeCount: sparkPoolMaxNodeCount
    }
    autoPause:{
      enabled: true
      delayInMinutes: 15
    }
    sparkVersion: '3.1'
  }
}

