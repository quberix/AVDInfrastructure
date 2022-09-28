//configure a Bastion including its subnet, public IP, the bastion itself and its diagnostics

//PARAMETERS
@description('Tags for the deployed resources')
param tags object

@description('Geographic Location of the Resources.')
param location string = resourceGroup().location

@description('Name of the bastion host')
param bastionHostName string

@description('Name of the bastion public ip address')
param bastionPublicIPName string

@description('Name of the bastion public ip address')
param bastionSku string = 'basic'

@description('Optional: The Vnet to which Bastion subnet is to be configured.  If not configured bastionSubnetID must be configured')
param bastionVnetName string = ''

@description('Optional: The Subnet CIDR to set up in the associated vnet.  Required if bastionVnetName is configured')
param bastionSubnetCIDR string = ''

@description('Optional: The subnet ID to which Bastion is to be associated.  If not configured then bastionVnetName/bastionSubnetCIDR must be')
param bastionSubnetID string = ''

@description('Optional - ID of the Log Analytics service to send debug info to.  Default: none')
param lawID string = ''

//VARIABLES
//Get the subnet ID: either it has been specified in params, found from existing subnet in vnet, or newly created subent in vnet
var subnetID = bastionSubnetID == '' ? ((bastionVnetName != '') && (bastionSubnetCIDR != '') ? BastionSubnetExist.id : BastionSubnet.id ) : bastionSubnetID

//Pull in the existing vnet if bastionVnetName is specified
resource BastionVnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = if (bastionVnetName != '') {
  name: bastionVnetName
}

//Create the bastion subnet if the CIDR has been specified
resource BastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if ((bastionVnetName != '') && (bastionSubnetCIDR != '')) {
  parent: BastionVnet
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: bastionSubnetCIDR
  }
}

//Look up the bastion subnet if only the vnet name is specified
resource BastionSubnetExist 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = if ((bastionVnetName != '') && (bastionSubnetCIDR == '')) {
  parent: BastionVnet
  name: 'AzureBastionSubnet'
}

resource BastionPIP 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: bastionPublicIPName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: bastionHostName
  location: location
  tags: tags
  sku: {
    name: bastionSku
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subnetID
          }
          publicIPAddress: {
            id: BastionPIP.id
          }
        }
      }
    ]
  }
}


//Bastion Diagnostics
resource bastionDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = if (lawID != '') {
  scope: bastionHost
  name: '${bastionHostName}-Bastion-diagnostics'
  properties: {
    workspaceId: lawID
    logs: [
      {
        category: 'BastionAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}
