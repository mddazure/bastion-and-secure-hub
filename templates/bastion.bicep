param bastionname string
param vnetname string
param location string
param tier string
param privateip bool
param bassubnetid string

resource bastion 'Microsoft.Network/bastionHosts@2023-09-01'= {
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
            privateIPAllocationMethod: 'Dynamic'
          }
          publicIPAddress:{}
        }
      }     
    ]
  }
}
