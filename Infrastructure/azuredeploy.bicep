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
param additionalTags object = { }

//VARIABLES
var rgName = toUpper('${orgCode}-RG-${product}-${localenv}')
var bastionName = toLower('${orgCode}-bastion-${product}-${localenv}')
var bastionPIPName = toLower('${orgCode}-bastion-pip-${product}-${localenv}')
//var rtName = toLower('${orgCode}-rt-${product}-${localenv}')

var tags = Config.outputs.tags


//RESOURCES
//Set up the RG
resource RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  //tags: defaultTags
}

//Pull in the Config - can't do this earlier unfortunatly as it needs to be drawn in again an existing RG
module Config '../Config/config.bicep'= {
  name: 'config'
  scope: RG
  params: {
    localenv: localenv
    location: location
    organisation: organisation
    orgCode: orgCode
    product: product
    additionalTags: additionalTags
  }
}

//Update the RG tags because we cannot do that in its initial deployment as we need to deploy
//the config module against the RG and the config module contains the tag content
module RGTag '../Modules/module_UpdateRGTags.bicep'= {
  name: 'RGTag'
  params: {
    rgName: rgName
    location: location
    tags: tags
  }
}

// Deploy log analytics
module LogAnalytics '../Modules/module_LogAnalytics.bicep' = {
  name: 'LogAnalytics'
  scope: RG
  params: {
    location: location
    tags: tags
    laName: Config.outputs.logAnalytics[localenv].name
  }
}

// Deploy core vnet and subnet
// Note: this will set the VNET DNS setting to a server which does not yet exist - AADDS or AD server is build in step 2
module VnetSnetNSG '../Modules/pattern_Vnet_Subnet_NSG.bicep' = {
  name: 'VnetSnetNSG'
  scope: RG
  params: {
    location: location
    tags: tags
    lawID: LogAnalytics.outputs.logAnalyticsID
    vnetObject: Config.outputs.vnetAll[localenv][product]
    newDeployment: true
  }
}

// Deploy Bastion
module Bastion '../Modules/module_Bastion.bicep' = {
  name: 'Bastion'
  scope: RG
  params: {
    location: location
    tags: tags
    lawID: LogAnalytics.outputs.logAnalyticsID
    bastionHostName: bastionName
    bastionPublicIPName: bastionPIPName
    bastionVnetName: Config.outputs.vnetCore[localenv][product].vnetName
  }
  dependsOn: [
    VnetSnetNSG
  ]
}

//var vnetConfig = Config.outputs.vnetCore[localenv][Config.outputs.adDomainSettings.vnetConfigID]

//Deploy a route table with route to the internet
// module RouteTableInternet '../Modules/module_UserDefinedRoute.bicep' = {
//   name: 'RouteTableInternet'
//   scope: RG
//   params: {
//     location: location
//     tags: tags
//     udrName: rtName
//     udrRouteName: 'internet'
//     nextHopType: 'Internet'
//     addressPrefix: '0.0.0.0/0'
//   }
// }

// //Apply the Route table to the AD Subnet
// module RouteTableADSnet '../Modules/module_UserDefinedRoute_Apply.bicep' = {
//   name: 'RouteTableADSnet'
//   scope: RG
//   params: {
//     udrID: RouteTableInternet.outputs.udrID
//     vnetName: vnetConfig.vnetName
//     subnetName: vnetConfig.subnets[Config.outputs.adDomainSettings.snetConfigID].name
//     subnetCidr: vnetConfig.subnets[Config.outputs.adDomainSettings.snetConfigID].cidr
    
//   }
// }


