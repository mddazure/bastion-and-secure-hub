param rgName string = 'vwan-bastion-test'
param location string = 'swedencentral'
param adminUsername string = 'AzureAdmin'
param adminPassword string = 'VwanBas-2024'

param vwanName string = 'vwan'
param hub0Range string = '192.168.0.0/24'
param hub1Range string = '192.168.1.0/24'
param spoke0Name string = 'spoke0'
param spoke1Name string = 'spoke1'
param spoke0Range string = '172.16.0.0/24'
param spoke1Range string = '172.16.1.0/24'
param spoke0DefaultSubRange string = '172.16.0.0/26'
param spoke0BastionSubRange string = '172.16.0.64/26'
param spoke1DefaultSubRange string = '172.16.1.0/26'
param spoke1BastionSubRange string = '172.16.1.64/26'

targetScope = 'subscription'

resource vwantestRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module vwan 'vwan.bicep' = {
  name: 'vwan'
  scope: vwantestRg
  dependsOn:[
    spoke0
    spoke1
  ]
  params: {
    vwanname: vwanName
    hub0range: hub0Range
    hub1range: hub1Range
    location: location
    spoke0id: spoke0.outputs.spokeid
    spoke1id: spoke1.outputs.spokeid
  }


}

module spoke0 'spoke.bicep' = {
  name: 'spoke0'
  scope: vwantestRg
  params: {
    vnetname: spoke0Name
    location: location
    vnetrange: spoke0Range
    defsubrange: spoke0DefaultSubRange
    bassubrange: spoke0BastionSubRange
  }
}

module spoke1 'spoke.bicep' = {
  name: 'spoke1'
  scope: vwantestRg
  params: {
    vnetname: spoke1Name
    location: location
    vnetrange: spoke1Range
    defsubrange: spoke1DefaultSubRange
    bassubrange: spoke1BastionSubRange
  }
}

module bastion0 'bastion.bicep' = {
  name: 'bastion0'
  scope: vwantestRg
  params: {
    bastionname: 'bastion0'
    vnetname: spoke0Name
    location: location
    tier: 'Premium'
    privateip: false
    bassubnetid: spoke0.outputs.bassubnetid
  }
}
