targetScope = 'subscription'

@description('Customer Name')
param customerName string

@allowed(['dev', 'test', 'prod'])
param environmentType string

@description('Location')
param location string

@description('Location Short Code')
param locationShortCode string

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

// Virtual Network Settings
param vnetAddressPrefix string
param subnet1AddressPrefix string

// Virtual Machine Settings
param vmUserName string

@secure()
param vmPassword string


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

var virtualMachineSettings object = {
  osType: 'Windows'
  zone: '1'
  vmSize: 'Standard_D4ds_v5'
  adminUsername: vmUserName
  adminPassword: vmPassword

}
//
// Azure Verified Modules
// No Hard Coded Values, all parameters are passed in from the main.bicepparam file

module createResourceGroup 'br/public:avm/res/resources/resource-group:0.4.3' = {
  name: 'create-resource-group'
  params: {
    name: resourceGroupName
    location: location
    tags: tags
  }
}

module createStorageAccount 'br/public:avm/res/storage/storage-account:0.32.0' = {
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

module createVirtualNetwork 'br/public:avm/res/network/virtual-network:0.7.2' = {
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

module createVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.21.0' = {
  name: 'create-virtual-machine'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'vm-${customerName}-bicep-example-${locationShortCode}'
    location: location
    zone: virtualMachineSettings.zone
    osType: virtualMachineSettings.osType
    adminUsername: virtualMachineSettings.adminUsername
    adminPassword: virtualMachineSettings.adminPassword
    vmSize: virtualMachineSettings.vmSize
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-Datacenter'
      version: 'latest'
    }
    osDisk: {
      name: 'osdisk-${customerName}-bicep-example-${locationShortCode}'
      caching: 'ReadWrite'
      createOption: 'FromImage'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    nicConfigurations: [
      {
        name: 'nic-${customerName}-bicep-example-${locationShortCode}'
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: createVirtualNetwork.outputs.subnetResourceIds[0]
          }
        ]
      }
    ]
    tags: tags
  }
  dependsOn: [
    createVirtualNetwork
  ]
}
