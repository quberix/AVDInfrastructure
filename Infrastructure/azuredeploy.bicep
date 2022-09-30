// This configures a set of core infrastructure required for the deployment of the AVD service
// this includes the vnets, subnets and other core services required for the solution

//It is configured to be deployed as a Subscription Scope and will create an RG based on the parameters provided.
//If you dont want to use this RG, then please create the RG yourself and change the RG resource creation below
//to an "Existing" resource.

//This will work for both a single subscription as well as a dev/prod subscription - just make sure the config details 
//are correct.

//this bicep will set some defaults - you can either change them in code, or change them via parameters e.g. location

//Set the scope - required so this can create the RG as well
targetScope = 'subscription'

//Parameters
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

@description('Default Tags to apply')
param tags object = { }

//Vars - Resource group names
var rgName = toUpper('${orgCode}-RG-${product}-${localenv}')

//Variables
var defaultTags = union({
  Environment: toUpper(localenv)
  Application: toUpper('${organisation} ${product}')
  Owner: toUpper('NHSE - ${organisation} - ${product}')
  Product: toUpper(product)
  Criticality: localenv == 'prod' ? 'Tier 1' : 'Tier 2'
 }, tags)


//RESOURCES
//Set up the RG
resource RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: defaultTags
}

//Pull in the Config - can't do this earlier unfortunatly as it needs to be drawn in again an existing RG
module Config '..//Config/config_common.bicep'= {
  name: 'config'
  scope: RG
  params: {
    localenv: localenv
    location: location
    organisation: organisation
    orgCode: orgCode
    product: product
    deploymentType: 'infrastructure'
  }
}

// Deploy log analytics
module LogAnalytics '../Modules/module_LogAnalytics.bicep' = {
  name: 'LogAnalytics'
  scope: RG
  params: {
    location: location
    tags: tags
    laName: toLower('${orgCode}-law-${product}-${localenv}')
  }
}

// Deploy core vnet and subnet
module VnetSnetNSG '../Modules/pattern_Vnet_Subnet_NSG.bicep' = {
  name: 'VnetSnetNSG'
  scope: RG
  params: {
    location: location
    tags: tags
    lawID: LogAnalytics.outputs.logAnalyticsID
    vnetObject: 
  }
}

// Deploy keyvault
// Deploy Bastion
// Deploy VM based AD server
