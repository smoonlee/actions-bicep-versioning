using 'main.bicep'

param customerName = 'bwc'
param environmentType = 'dev'
param location = 'westeurope'
param locationShortCode = 'weu'

param vnetAddressPrefix = '10.0.0.0/24'
param subnet1AddressPrefix = '10.0.0.0/24'

param vmUserName = 'azureuser'

param vmPassword = 'P@ssw0rd1234'
