//Virtual networking for the UDAL DATA VNET
param dnsSettings object
param subscriptions object

//Inbound from AVD (3389-WindowsVirtualDesktop) plus vnet and LB
var avdInboundStandardRulesDev = [
  {
    name: 'Allow-AVD-Service-Inbound'
    properties: {
      description: 'Permit access from the Microsoft AVD service to the desktops (DEV)'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: 'WindowsVirtualDesktop'
      destinationAddressPrefix: '10.210.0.0/18'
      access: 'Allow'
      priority: 500
      direction: 'Inbound'
    }
  }
]

var avdInboundStandardRulesProd = [
  {
    name: 'Allow-AVD-Service-Inbound'
    properties: {
      description: 'Permit access from the Microsoft AVD service to the desktops (PROD)'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: 'WindowsVirtualDesktop'
      destinationAddressPrefix: '10.211.0.0/18'
      access: 'Allow'
      priority: 500
      direction: 'Inbound'
    }
  }
]

var vnets = {
  //Data Development
  'udal-vnet-wvd': {
    // dev: {
    //   vnetName: 'udal-vnet-wvd-dev'
    //   vnetCidr: '10.201.0.0/17'
    //   dnsServers: dnsSettings.aadds
    //   RG: 'UDAL-RG-WVD-DEV'
    //   subscriptionID: subscriptions.udal.dev.id
    //   peerOut: true
    //   peerIn: true
    //   subnets: [
    //     {
    //       name: 'udal-snet-analyst-dev'
    //       cidr: '10.201.0.0/21'
    //       nsgName: 'udal-nsg-pool-wvd-dev'
    //       nsgSecurityRules: []
    //       routeTable: 'udal-route-wvd-dev'
    //       delegation: []
    //     }
    //     {
    //       name: 'udal-snet-developer-dev'
    //       cidr: '10.201.8.0/23'
    //       nsgName: 'udal-nsg-pool-wvd-dev'
    //       nsgSecurityRules: []
    //       routeTable: 'udal-route-wvd-dev'
    //       delegation: []
    //     }
    //     {
    //       name: 'udal-snet-pep-wvd-dev'
    //       cidr: '10.201.127.64/27'
    //       nsgName: 'udal-nsg-pool-wvd-dev'
    //       nsgSecurityRules: []
    //       routeTable: 'udal-route-wvd-dev'
    //       delegation: []
    //     }
    //   ]
    //   peering: [
    //     //Core
    //     'udal-vnet-aads-prod'
    //     'udal-vnet-userprofile-prod'
    //     'udal-vnet-coreserver-dev'
    //     'udal-vnet-boundary-dev'
    //     //UDAL Data
    //     'udal-vnet-data-dev'
    //     'udal-vnet-drop-dev'        
    //   ]
    // }
    // prod: {
    //   vnetName: 'udal-vnet-wvd-prod'
    //   vnetCidr: '10.204.0.0/17'
    //   dnsServers: dnsSettings.aadds
    //   RG: 'UDAL-RG-WVD-PROD'
    //   subscriptionID: subscriptions.udal.prod.id
    //   peerOut: true
    //   peerIn: true
    //   subnets: [
    //     {
    //       name: 'udal-snet-analyst-prod'
    //       cidr: '10.204.0.0/21'
    //       nsgName: 'udal-nsg-pool-wvd-prod'
    //       nsgSecurityRules: []
    //       routeTable: 'udal-route-wvd-prod'
    //       delegation: []
    //     }
    //     {
    //       name: 'udal-snet-pep-wvd-prod'
    //       cidr: '10.204.127.64/27'
    //       nsgName: 'udal-nsg-pool-wvd-prod'
    //       nsgSecurityRules: []
    //       routeTable: 'udal-route-wvd-prod'
    //       delegation: []
    //     }
    //   ]
    //   peering: [
    //     //Core
    //     'udal-vnet-aads-prod'
    //     'udal-vnet-userprofile-prod'
    //     'udal-vnet-coreserver-prod'
    //     'udal-vnet-boundary-prod'
    //     //UDAL Data
    //     'udal-vnet-data-dev'
    //     'udal-vnet-data-test'
    //     'udal-vnet-data-uat'
    //     'udal-vnet-data-prod'
    //     'udal-vnet-data-gateway-dev'
    //     'udal-vnet-data-gateway-test'
    //     'udal-vnet-data-gateway-uat'
    //     'udal-vnet-data-gateway-prod'
    //     //UDAL DropBox
    //     'udal-vnet-drop-dev'
    //     'udal-vnet-drop-test'
    //     'udal-vnet-drop-uat'
    //     'udal-vnet-drop-prod'
    //     //UDAL Sandbox
    //     'udal-vnet-data-sandbox-prod'
    //     //IDE
    //     'gisd-vnet-gis'
    //     'gisp-vnet-gis'
    //     'mpid-vnet-mpi'
    //     'mpip-vnet-mpi'
    //     'ide-vnet-esr-dev'
    //     'ide-vnet-esr-prod'
    //     'ide-vnet-pcare-dev'
    //     'ide-vnet-pcare-prod'
    //   ]
    // }
  }
}

output configVnetAVD object = vnets
