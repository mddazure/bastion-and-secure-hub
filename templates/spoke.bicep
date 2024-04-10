param vnetname string
param location string
param vnetrange string
param defsubrange string
param bassubrange string

resource spoke 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetname
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        vnetrange
      ]
    }
  }
}
resource defsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01'={
  parent: spoke
  name: 'default'
  properties:{
    addressPrefix: defsubrange
  }
}
resource bassubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01'={
  parent: spoke
  name: 'AzureBastionSubnet'
  dependsOn:[
    defsubnet
  ]
  properties:{
    addressPrefix: bassubrange
  }
}

output spokeid string = spoke.id
output bassubnetid string = bassubnet.id
