param bastionname string
param location string
param tier string
param privateip bool = false
param bassubnetid string

resource bastion 'Microsoft.Network/bastionHosts@2024-01-01' ={
  name: bastionname
  location: location
  sku: {
    name: tier
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
