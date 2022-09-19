//Builds a private endpoint PEP to DNS (if specified)
//Note it is not possible to get the Private IP address of the PEP as an output.  You need
//to use the NIC ID and/or name to return that information from the calling module.

//PARAMETERS
@description('Tags for the deployed resources')
param tags object

@description('Geographic Location of the Resources.')
param location string = resourceGroup().location

@description('The name of the private endpoint')
param privateEndpointName string

@description('Optional - The entry to put in the DNS record.  Requires dnsConfig')
param dnsName string = ''

@description('DNS settings from the Common Config (or similar)')
param dnsConfig object

@description('Network config for Private endpoint (Common Config->vnet->localenv) or similar')
param vnetConfig object = {}

@description('Subnet to deploy endpoint')
param endpointSnetName string = ''

@description('The ID of the Service from which to create an endpoint (e.g. storage, keyvault etc.)')
param serviceID string

@description('The Service Type - this will determine which resource groupIDs and DNS services are used')
param serviceType string


//VARIABLES
var groupId = dnsConfig.privateDNSConfig[toLower(serviceType)].pepGroupID 

//configure dns scope settings or none if the type is of DataFactory.  Reason for this is the scope of the module needs to be valid even if not used
//this is a bit of a cludge but currently this is required to overcome issues with how bicep manages resources within conditional deployment
var dnsRG = serviceType != 'datafactory' ? dnsConfig.privateDNSConfig['${serviceType}'].RG : resourceGroup().name
var dnsSubID = serviceType != 'datafactory' ? dnsConfig.privateDNSConfig['${serviceType}'].subscription : subscription().subscriptionId

//Get the Subnet ID
resource Subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  name: '${vnetConfig.vnetName}/${endpointSnetName}'
  scope: resourceGroup(vnetConfig.subscriptionID,vnetConfig.RG)
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: Subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: serviceID
          groupIds: [
            groupId 
          ]
        }
      }
    ]
  }
}

//Get the nic created by the private endpoint
module pepNICIP 'module_PrivateEndpoint_GetNICIP.bicep' = {
  name: 'pepNICIP'
  params: {
    nicName: last(split(privateEndpoint.properties.networkInterfaces[0].id,'/'))
  }
}


//If specified, create the DNS entry as well - DNS module needs scoping to run correctly
module DNSRecord 'module_DNSRecord_A.bicep' = if (dnsName != '') {
  name: 'dnsRecord'
  scope: resourceGroup(dnsSubID,dnsRG)
  params: {
    recordIPAddress: pepNICIP.outputs.nicIP
    recordName: dnsName
    dnsConfig: dnsConfig
    dnsResourceType: dnsName == '' ? 'none' : serviceType
  }
  dependsOn: [
    pepNICIP
  ]
}

output PrivateEndpointNicID string = privateEndpoint.properties.networkInterfaces[0].id
output PrivateEndpointNicName string = last(split(privateEndpoint.properties.networkInterfaces[0].id,'/'))
output PrivateEndpointNicIP string = pepNICIP.outputs.nicIP
