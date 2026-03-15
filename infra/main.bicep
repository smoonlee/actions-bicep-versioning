targetScope = 'subscription'

@description('Customer Name')
param customerName string

@allowed(['dev', 'test', 'prod'])
param environmentType string

@description('Location')
param location string

@description('Location Short Code')
param locationShortCode string

param vnetAddressPrefix string
param subnet1AddressPrefix string

param tags object = {
  'Customer Name': customerName
  Environment: environmentType
  'Deployed On': utcNow()
}

//
//

param resourceGroupName string = 'rg-${customerName}-bicep-example-${locationShortCode}'
param storageAccountName string = 'st${customerName}bicepexample${locationShortCode}'
param virtualNetworkName string = 'vnet-${customerName}-bicep-example-${locationShortCode}'

var virtualNetworkSettings object = {
  addressPrefixes: [
    vnetAddressPrefix
  ]
  subnets: [
    {
      name: 'subnet1'
      addressPrefix: subnet1AddressPrefix
    }
  ]
}

//
// Azure Verified Modules
// No Hard Coded Values, all parameters are passed in from the main.bicepparam file

module createResourceGroup 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: 'create-resource-group'
  params: {
    name: resourceGroupName
    location: location
    tags: tags
  }
}

module createStorageAccount 'br/public:avm/res/storage/storage-account:0.30.0' = {
  name: 'create-storage-account'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: storageAccountName
    skuName: 'StandardV2_LRS'
    location: location
    tags: tags
  }
  dependsOn: [
    createResourceGroup
  ]
}

module createVirtualNetwork 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'create-virtual-network'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: virtualNetworkName
    addressPrefixes: virtualNetworkSettings.addressPrefixes
    subnets: virtualNetworkSettings.subnets
    tags: tags
  }
  dependsOn: [
    createResourceGroup
  ]
}
