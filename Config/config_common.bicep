@allowed([
  'dev'
  'prod'
])
@description('The local environment identifier.  Default: dev')
param localenv string = 'dev'

@description('Location of the Resources. Default: UK South')
param location string = 'UK South'

@description('The default organisation hosting the application/s.  Default: NHSEI')
param organisation string = 'Quberatron'

@description('The application name.  This forms the first part of resource names e.g. qbx-<product>-<resource>-<environment>.  Default: qbx.')
param orgCode string = 'qbx'

@description('The name of the product being deployed.  This forms the second part of a resource name e.g. <orgCode>-core-<resource>-<environment>.  Default: Core')
param product string = 'core'

@description('the domain name being used to deploy resources to.  Default: quberix.co.uk')
param domain string = 'quberix.co.uk'

@description('Object of additional tags to add.  Optional.  Default: {} (empty object)')
param additionalTags object = {}

//VARIABLES
//group together the common settings
var commonSettings = {
  organisation: organisation
  orgCode: orgCode
  product: product
  location: location
  environment: toLower(localenv)
  domainName: domain
}

//More for reference, this is a list of the default tags being deployed on each resource.
var defaultTags = union({
  Environment: toUpper(localenv)
  Product: toUpper(product)
  Owner: toUpper(organisation)
  Criticality: toLower(localenv) == 'prod' ? 'Tier 1' : 'Tier 2'
}, additionalTags)


//List of all subscriptions by environmental reference
var subscriptions = {
  dev: {
    name: 'core-dev'
    id: 'c942a6a9-706e-4827-9cb7-36f38f1aa152'
  }
  prod: {
    name: 'core-prod'
    id: '57bd7e3b-c56c-4195-b0f0-da1a00509a48'
  }
}

//DNS Settings for various DNS services.  this will be the DNS IP addresses of any deployed AADDS or AD server
var dnsServers = {
  ad: [
    '10.0.2.4'
    '10.0.2.5'
  ]
}

// Provides the context and configuration settings for the Private DNS zones beign set up for an internal deployment.  this is where all
// Private Endpoints will be registered.
var privateDNSConfig = {
  blob: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    RG: 'UDAL-RG-IDENTITY'
    subscription: subscriptions.prod.id
    pepGroupID: 'blob'
  }
  file: {
    name: 'privatelink.file.${environment().suffixes.storage}'
    RG: 'UDAL-RG-IDENTITY'
    subscription: subscriptions.prod.id
    pepGroupID: 'file'
  }
  keyvault: {
    name: 'privatelink.vaultcore.azure.net'
    RG: 'UDAL-RG-IDENTITY'
    subscription: subscriptions.prod.id
    pepGroupID: 'vault'
  }
  web: {
    name: 'privatelink.azurewebsites.net'
    RG: 'UDAL-RG-IDENTITY'
    subscription: subscriptions.prod.id
    pepGroupID: 'sites'
  }
  logicapp: {
    name: 'privatelink.azurewebsites.net'
    RG: 'UDAL-RG-IDENTITY'
    subscription: subscriptions.prod.id
    pepGroupID: 'sites'
  }
  automation: {
    name: 'privatelink.azure-automation.net'
    RG: 'UDAL-RG-IDENTITY'
    subscription: subscriptions.prod.id
    pepGroupID: 'Webhook'
  }
}

//Log Analytics Settings
var logAnalytics = {
  dev: {
    rg: toUpper('${orgCode}-RG-DIAGLOGS-DEV')
    name: toLower('${orgCode}-law-infrastructure-dev')
    storageName: toLower('${orgCode}stinfracorediagdev')
    aaAccountName: toLower('${orgCode}-aa-infrastructure-dev')
    subscription: subscriptions.dev.id
    solutions: 'Updates,ChangeTracking,AntiMalware,Security,SecurityCenterFree,KeyVaultAnalytics,NetworkMonitoring,VMInsights'
  }
  prod: {
    rg: toUpper('${orgCode}-RG-DIAGLOGS-PROD')
    name: toLower('${orgCode}-law-infrastructure-prod')
    storageName: toLower('${orgCode}stinfracorediagprod')
    subscription: subscriptions.prod.id
  }
}

var adDomainSettings = {
  domainName: domain
  identityKeyVault: 'coreIdentity'
  ouPaths: {
    grouper: 'OU=Grouper,OU=Servers,OU=Environments,DC=udal,DC=nhs,DC=uk'
    sas: 'OU=SASServer,OU=Servers,OU=Environments,DC=udal,DC=nhs,DC=uk'
  }
}

var systemKeyVaults = {
  coreIdentity: {
    name: toLower('${orgCode}-kv-identity')
    subscription: subscriptions.prod.id
    RG: toUpper('${orgCode}-RG-IDENTITY')
  }
}

//Bastion Settings - default settings for the Bastion
var coreBastionConfig = {
  name: toLower('${orgCode}-bastion-dev')
  sku: 'Basic'
  pipName: toLower('${orgCode}-pip-bastion-dev')
}

// var commonVMConfigs = {
//   imageGallery: {
//     sharedImageGallerySubscriptionID: subscriptions.udal[localenv].id
//     sharedImageGalleryRG: toUpper('${application}-RG-IMAGES-${localenv}')
//     sharedImageGalleryName: toLower('${application}_sig_${localenv}')
//   }
//   windows: {
//     //Makes up the start and end of a wrapper around the VM/VMSS - XML
//     //${wadcfgxstart}<resource specific>${wadcfgxend}
//     //e.g. base64(${wadcfgxstart}/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachines/test-vm-dev${wadcfgxend})
//     vmLogs_Start: '${wadlogs}${wadperfcounters1}${wadperfcounters2}<Metrics resourceId="'
//     vmLogs_End: '"><MetricAggregation scheduledTransferPeriod="PT1H"/><MetricAggregation scheduledTransferPeriod="PT1M"/></Metrics></DiagnosticMonitorConfiguration></WadCfg>' 
//   }    
// }

// //Role Assignment Configuration
// var roleAssignmentConfig = {
//   StorageBlobDataReader: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
// }


// //Peering Settings - this sets the default config for the majority of the peering on the platform
// var peeringConfig = {
//   trafficToRemote: true
//   trafficForwardedFromRemote: false
//   useLocalGateway: false
//   useRemoteGateway: false
// }

//Default NSG Rules


//Core networks
module CoreVnets 'config_network_core.bicep' = {
  name: 'CoreVnets'
  params: {
    localenv: localenv
    orgCode: orgCode
    product: 'core'
    dnsSettings: dnsServers.ad
    subscriptions: subscriptions
  }
}

//AVD Networks
module AVDVnets 'config_network_avd.bicep' = {
  name: 'AVDVnets'
  params: {
    localenv: localenv
    orgCode: orgCode
    product: 'avd'
    dnsSettings: dnsServers.ad
    subscriptions: subscriptions
  }
}


// //Pull all the vnets into a single object
var vnetConfigs = union(CoreVnets.outputs.configVnet,AVDVnets.outputs.configVnet)

output tags object = defaultTags
output common object = commonSettings
output subscriptions object = subscriptions
output logAnalytics object = logAnalytics
output DNS object = dnsServers
output privateDNSSettings object = privateDNSConfig
output systemKeyvaults object = systemKeyVaults
output adDomainSettings object = adDomainSettings
output coreBastionConfig object = coreBastionConfig
output vnetAll object = vnetConfigs


// output roleAssignmentConfig object = roleAssignmentConfig
// output vnetCore object = CoreVnets.outputs.configVnetCore
// output vnetData object = DataVnets.outputs.configVnetData
// output vnetAVD object = AVDVnets.outputs.configVnetAVD
// output vnetAVDCore object = AVDVnets.outputs.configVnetAVDCore
// output vnetIDE object = IDEVnets.outputs.configVnetIDE

// output vnetPeering object = peeringConfig
// output coreFirewallConfigNoEnv object = coreFirewallDetailsCommon
// output coreFirewallConfig object = coreFirewallConfig
// output commonVMSettings object = commonVMConfigs
