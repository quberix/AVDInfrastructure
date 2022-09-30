//Virtual networking for the UDAL DATA VNET
param localenv string
param dnsSettings array
param subscriptions object
param orgCode string
param product string = 'core'

var defaultRGNoEnv = '${orgCode}-RG-${product}'
var coreVnetNameNoEnv = '${orgCode}-vnet-${product}'
var coreSnetNameNoEnv = '${orgCode}-snet-${product}'
var coreNSGNameNoEnv = '${orgCode}-nsg-${product}'

var vnets = {
  dev: {
    '${product}': {
      vnetName: toLower('${coreVnetNameNoEnv}-${localenv}')
      vnetCidr: '10.100.0.0/24'
      dnsServers: dnsSettings
      RG: toUpper('${defaultRGNoEnv}-${localenv}')
      subscriptionID: subscriptions.dev.id
      peerOut: true
      peerIn: true
      subnets: {
        adserver: {
          name: toLower('${coreSnetNameNoEnv}-adserver-${localenv}')
          cidr: '10.100.0.0/26'
          nsgName: toLower('${coreNSGNameNoEnv}-adserver-${localenv}')
          nsgSecurityRules: []
        }
        bastion: {
          name: 'azure-bastion-subnet'
          cidr: '10.100.0.128/26'
          nsgName: ''
          nsgSecurityRules: []
        }
      }
      peering: []
    }
  }
  prod: {
    '${product}': {
      vnetName: toLower('${coreVnetNameNoEnv}-${localenv}')
      vnetCidr: '10.101.0.0/24'
      dnsServers: dnsSettings
      RG: toUpper('${defaultRGNoEnv}-${localenv}')
      subscriptionID: subscriptions.dev.id
      peerOut: true
      peerIn: true
      subnets: {
        adserver: {
          name: toLower('${coreSnetNameNoEnv}-adserver-${localenv}')
          cidr: '10.101.0.0/26'
          nsgName: toLower('${coreNSGNameNoEnv}-adserver-${localenv}')
          nsgSecurityRules: []
        }
        bastion: {
          name: 'azure-bastion-subnet'
          cidr: '10.101.0.128/26'
          nsgName: ''
          nsgSecurityRules: []
        }
      }
      peering: []
    }
  }
}



output configVnet object = vnets
