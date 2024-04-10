param vwanname string
param hub0range string
param hub1range string 
param location string
param spoke0id string
param spoke1id string

resource vwan 'Microsoft.Network/virtualWans@2023-09-01' = {
  name: vwanname
  location: location
  properties:{
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    type: 'Standard'
  }
}

resource hub0 'Microsoft.Network/virtualHubs@2021-08-01' = {
  name: 'hub0'
  location: location
  properties: {
    addressPrefix: hub0range
    virtualWan: {
      id: vwan.id
    }
  }
}
resource spoke0hub0 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-09-01' = {
  parent: hub0
  name: 'spoke0hub0'
  dependsOn:[
    hub0fw
    hub1fw
  ]
  properties:{
    remoteVirtualNetwork: {
      id: spoke0id
    }
    allowRemoteVnetToUseHubVnetGateways: true
    allowHubToRemoteVnetTransit: true
    enableInternetSecurity: true
  }
}


resource hub1 'Microsoft.Network/virtualHubs@2021-08-01' = {
  name: 'hub1'
  location: location
  properties: {
    addressPrefix: hub1range
    virtualWan: {
      id: vwan.id
    }
  }
}
resource spoke1hub1 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-09-01' = {
  parent: hub1
  name: 'spoke01hub1'
  dependsOn:[
    hub0fw
    hub1fw
  ]
  properties:{
    remoteVirtualNetwork: {
      id: spoke1id
    }
    allowRemoteVnetToUseHubVnetGateways: true
    allowHubToRemoteVnetTransit: true
    enableInternetSecurity: true
  }
}

resource fwpol 'Microsoft.Network/firewallPolicies@2023-09-01' = {
  name: 'fwpol'
  location: location
  properties:{
    }
}

resource fwpolnwpolrcgroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' ={
  parent: fwpol
  name: 'fwpolnwpolrcgroup'
  properties: {
    priority: 250
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'defaultAllowAll'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses:[
              '*'
            ]
            destinationAddresses:[
              '*'
            ]
          }
          ]

       }
    ]
   }
}


resource hub0fw 'Microsoft.Network/azureFirewalls@2023-09-01'= {
  name:'hub0fw'
  location: location
  properties:{
    sku:{
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    virtualHub:{
      id: hub0.id
    }
    hubIPAddresses:{
    publicIPs:{
      count: 1
    }
    }
  }
}

resource hub1fw 'Microsoft.Network/azureFirewalls@2023-09-01'= {
  name:'hub1fw'
  location: location
  properties:{
    sku:{
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    virtualHub:{
      id: hub1.id
    }
    hubIPAddresses:{
    publicIPs:{
      count: 1
    }
    }
  }
}

