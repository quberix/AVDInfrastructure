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

var vnets = {
  dev: {
    '${product}': {
      vnetName: toLower('${coreVnetNameNoEnv}-${localenv}')
      vnetCidr: '10.201.0.0/17'
      dnsServers: dnsSettings
      RG: toUpper('${defaultRGNoEnv}-${localenv}')
      subscriptionID: subscriptions.dev.id
      peerOut: true
      peerIn: true
      subnets: {
        adserver: {
          name: toLower('${coreSnetNameNoEnv}-adserver-${localenv}')
          cidr: '10.201.0.0/21'
          nsgName: toLower('${coreNSGNameNoEnv}-adserver-${localenv}')
          nsgSecurityRules: []
          routeTable: toLower('${coreRTNameNoEnv}-adserver-${localenv}')
          delegation: []
        }
        bastion: {
          name: 'azure-bastion-subnet'
          cidr: '10.201.0.0/21'
          nsgName: ''
          nsgSecurityRules: []
          routeTable: ''
          delegation: []
        }
      }
      peering: []
    }
  }
}

output configVnet object = vnets
