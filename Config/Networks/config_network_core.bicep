//Virtual networking for the UDAL DATA VNET
param dnsSettings object
param subscriptions object
param orgCode string
param product string = 'core'

var defaultRGNoEnv = '${orgCode}-RG-${product}'
var coreVnetNameNoEnv = '${orgCode}-vnet-${product}'
var coreSnetNameNoEnv = '${orgCode}-snet-${product}'
var coreNSGNameNoEnv = '${orgCode}-nsg-${product}'

module BastionNSGRules '../NSGRules/nsgrules_Bastion.bicep' = {
  name: 'BastionNSGRules'
}

module ADServerNSGRules '../NSGRules/nsg_rules_AD.bicep' = {
  name: 'ADServerNSGRules'
}

module PEPADServiceNSGRules '../NSGRules/nsg_rules_Endpoints.bicep' = {
  name: 'PEPServiceNSGRules'
}


var vnets = {
  dev: {
    '${product}': {
      vnetName: toLower('${coreVnetNameNoEnv}-dev')
      vnetCidr: '10.100.0.0/24'
      dnsServers: dnsSettings.dev.ad
      RG: toUpper('${defaultRGNoEnv}-dev')
      subscriptionID: subscriptions.dev.id
      peerOut: true
      peerIn: true
      subnets: {
        adserver: {
          name: toLower('${coreSnetNameNoEnv}-adserver-dev')
          cidr: '10.100.0.0/26'
          nsgName: toLower('${coreNSGNameNoEnv}-adserver-dev')
          nsgSecurityRules: ADServerNSGRules.outputs.inbound
        }
        bastion: {
          name: 'AzureBastionSubnet'
          cidr: '10.100.0.128/26'
          nsgName: toLower('${coreNSGNameNoEnv}-bastion-dev')
          nsgSecurityRules: BastionNSGRules.outputs.all
        }
      }
      peering: []
    }
  }
  prod: {
    '${product}': {
      vnetName: toLower('${coreVnetNameNoEnv}-prod')
      vnetCidr: '10.101.0.0/24'
      dnsServers: dnsSettings.prod.ad
      RG: toUpper('${defaultRGNoEnv}-prod')
      subscriptionID: subscriptions.dev.id
      peerOut: true
      peerIn: true
      subnets: {
        adserver: {
          name: toLower('${coreSnetNameNoEnv}-adserver-prod')
          cidr: '10.101.0.0/26'
          nsgName: toLower('${coreNSGNameNoEnv}-adserver-prod')
          nsgSecurityRules: []
        }
        bastion: {
          name: 'AzureBastionSubnet'
          cidr: '10.101.0.128/26'
          nsgName: toLower('${coreNSGNameNoEnv}-bastion-prod')
          nsgSecurityRules: BastionNSGRules.outputs.all
        }
      }
      peering: []
    }
  }
}



output configVnet object = vnets
