targetScope = 'subscription'

param location string = 'westus2'
param prefix string
param postfix string
param env string 
param objectID string
param sqladministratorLoginPassword string
// param synapsedatalakegen2name string
// param synapsedatalakegen2filesystemname string


param tags object = {
  Owner: 'fasthack'
  Project: 'fasthack'
  Environment: env
  Toolkit: 'bicep'
  Name: prefix
}

var baseName  = '${prefix}${postfix}${env}'
var resourceGroupName = 'rg-${baseName}'


resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroupName
  location: location

  tags: tags
}


// Storage Account
module st './modules/storage_account.bicep' = {
  name: 'st'
  scope: resourceGroup(rg.name)
  params: {
    name: 'st${baseName}'
    location: location
    tags: tags
  }
}

// data lake

module dl './modules/datalake_account.bicep' = {
  name: 'dl'
  scope: resourceGroup(rg.name)
  params: {
    name: 'dl${baseName}'
    location: location
    tags: tags
  }
}

// key vault

module kv './modules/key_vault.bicep' = {
  name: 'kv'
  scope: resourceGroup(rg.name)
  params: {
    name: 'akv${baseName}'
    location: location
    tags: tags
    objectID: objectID
  }
}

//sql server

module sqlsvr './modules/sqlserver.bicep' = {
  name: 'sqlsvr'
  scope: resourceGroup(rg.name)
  params: {
    name: 'sqlsvr${baseName}'
    location: location
    tags: tags
    administratorLogin: 'rootuser'
    administratorLoginPassword: sqladministratorLoginPassword
    databaseName: 'sampledb'

  }
}


// synapse workspace

module synapse './modules/synapse.bicep' = {
  name: 'synapse'
  scope: resourceGroup(rg.name)
  params: {
    synapseName: 'synw${baseName}'
    location: location
    tags: tags
    administratorLogin: 'rootuser'
    administratorLoginPassword: sqladministratorLoginPassword
    datalakegen2name: 'adlsyn${baseName}'
    defaultDataLakeStorageFilesystemName: 'root'
    dataLakeUrlFormat: 'https://{0}.dfs.core.windows.net'
    sparkPoolName: 'sparkpool'
    sparkPollNodeSize: 'small'
    sparkPoolMinNodeCount: 3
    sparkPoolMaxNodeCount: 3
  }
}
