param bastionname string
param vnetname string
param location string
param tier string
param privateip bool
param bassubnetid string

resource bastion 'Microsoft.Network/bastionHosts@2024-01-01' ={
  name: bastionname
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    scaleUnits: 2
    enableIpConnect: true
    enableShareableLink: true
    ipConfigurations: [
      {
        name: 'ipConf'
        properties:{
          subnet: {
            id: bassubnetid
          }
          privateIPAllocationMethod: 'Static'
          publicIPAddress:{
            id: bastionPublicIp.id
          }
        }
      }     
    ]
  }
}
resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: '${bastionname}PublicIp'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}
