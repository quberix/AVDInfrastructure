//Virtual networking for the UDAL DATA VNET
param localenv string
param dnsSettings array
param subscriptions object
param orgCode string
param product string = 'core'

var defaultRGNoEnv = '${orgCode}-RG-${product}}'
var coreVnetNameNoEnv = '${orgCode}-vnet-${product}}'
var coreSnetNameNoEnv = '${orgCode}-snet-${product}}'
var coreNSGNameNoEnv = '${orgCode}-nsg-${product}}'
var coreRTNameNoEnv = '${orgCode}-rt-${product}}'

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
  dev: {
    avd: {
      vnetName: toLower('${coreVnetNameNoEnv}-avd-${localenv}')
      vnetCidr: '10.201.0.0/17'
      dnsServers: dnsSettings
      RG: toUpper('${defaultRGNoEnv}-${localenv}')
      subscriptionID: subscriptions.dev.id
      peerOut: true
      peerIn: true
      subnets: {
        analyst: {
          name: toLower('${coreSnetNameNoEnv}-avd-analyst-${localenv}')
          cidr: '10.201.0.0/21'
          nsgName: toLower('${coreNSGNameNoEnv}-avd-analyst-${localenv}')
          nsgSecurityRules: avdInboundStandardRulesDev
          routeTable: toLower('${coreRTNameNoEnv}-avd-analyst-${localenv}')
          delegation: []
        }
      }
      peering: []
    }
  }
}

output configVnet object = vnets
