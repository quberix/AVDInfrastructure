//Virtual networking for the UDAL DATA VNET
param localenv string
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
      vnetName: toLower('${coreVnetNameNoEnv}-${localenv}')
      vnetCidr: '10.100.0.0/24'
      dnsServers: dnsSettings[localenv]
      RG: toUpper('${defaultRGNoEnv}-${localenv}')
      subscriptionID: subscriptions.dev.id
      peerOut: true
      peerIn: true
      subnets: {
        adserver: {
          name: toLower('${coreSnetNameNoEnv}-adserver-${localenv}')
          cidr: '10.100.0.0/26'
          nsgName: toLower('${coreNSGNameNoEnv}-adserver-${localenv}')
          nsgSecurityRules: ADServerNSGRules.outputs.inbound
        }
        bastion: {
          name: 'AzureBastionSubnet'
          cidr: '10.100.0.128/26'
          nsgName: toLower('${coreNSGNameNoEnv}-bastion-${localenv}')
          nsgSecurityRules: BastionNSGRules.outputs.all
        }
        endpoints: {
          name: toLower('${coreSnetNameNoEnv}-pep-${localenv}')
          cidr: '10.100.0.192/26'
          nsgName: toLower('${coreNSGNameNoEnv}-pep-${localenv}')
          nsgSecurityRules: PEPADServiceNSGRules.outputs.pepHttpsInbound
        }
      }
      peering: []
    }
  }
  prod: {
    '${product}': {
      vnetName: toLower('${coreVnetNameNoEnv}-${localenv}')
      vnetCidr: '10.101.0.0/24'
      dnsServers: dnsSettings[localenv]
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
          name: 'AzureBastionSubnet'
          cidr: '10.101.0.128/26'
          nsgName: toLower('${coreNSGNameNoEnv}-bastion-${localenv}')
          nsgSecurityRules: BastionNSGRules.outputs.all
        }
        endpoints: {
          name: toLower('${coreSnetNameNoEnv}-pep-${localenv}')
          cidr: '10.101.0.192/26'
          nsgName: toLower('${coreNSGNameNoEnv}-pep-${localenv}')
          nsgSecurityRules: PEPADServiceNSGRules.outputs.pepHttpsInbound
        }
      }
      peering: []
    }
  }
}



output configVnet object = vnets
