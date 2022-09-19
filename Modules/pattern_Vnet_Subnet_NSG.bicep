//This pattern is used to deploy a virtual network, add an array of subnets and assign a default NSGs to each subnet.
//This does not deploy a route table or assign it to any subnets

//Requires a vnet object in the form:
// {
//   vnetName: 'name without pre or postfix'     (string)
//   vnetCidr: 'x.x.x.x/xx'                      (string)
//   dnsServers: ['dns server1','dns server 2']  (array)
//   subnets: [
//     {
//        name: 'subnet name'
//        nsgName: 'nsg name'
//        cidr: 'x.x.x.x/x'
//        routeTable: 'rt name'
//        nsgSecurityRules: [array of nsg rules]
//        delegation: [array of subnet delegations]
//      }
//   ]
// }

//NSG Security Rules example
// nsgSecurityRules: [
//   {
//     name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
//     properties: {
//       description: 'Required for worker nodes communication within a cluster.'
//       protocol: '*'
//       sourcePortRange: '*'
//       destinationPortRange: '*'
//       sourceAddressPrefix: 'VirtualNetwork'
//       destinationAddressPrefix: 'VirtualNetwork'
//       access: 'Allow'
//       priority: 100
//       direction: 'Inbound'
//     }
//   }
// ]

//Delegation Example
// [
//   {
//     name: 'ide-snet-delegation-pcare-dbpcareprivate-dev'
//     properties: {
//       serviceName: 'Microsoft.Databricks/workspaces'
//     }
//   }
// ]

@description('Tags for the deployed resources')
param tags object

@description('Geographic Location of the Resources.')
param location string = resourceGroup().location

@description('Optional - Whether this is a new or existing deployment.  Default: false')
param newDeployment bool = false

@description('Optional - ID of the Log Analytics service to send debug info to.  Default: none')
param lawID string = ''

@description('The vnet and subnet object to deploy')
param vnetObject object

@description('Optional: The route table to apply to the subnets.  Default: empty string (aka none)')
param routeTableID string = ''

@description('optional - Provide a list of service endpoints for the Subnet')
param serviceEndPoints array = []

//VARIABLES
var subnetList = vnetObject.subnets
var vnetName = vnetObject.vnetName
var vnetCidr = vnetObject.vnetCidr
var dnsServers = empty(vnetObject.dnsServers) ? [] : vnetObject.dnsServers

//Create the NSGs
//Workaround: A resource is evaluated even if it is not deployed, so it needs to have a name, even one not used.
@batchSize(1)
resource NSG 'Microsoft.Network/networkSecurityGroups@2021-02-01'  = [for (subnet,i) in subnetList: if (subnet.nsgName != '') {
  name: subnet.nsgName != '' ? subnet.nsgName : 'none${i}'
  location: location
  tags: tags
  properties: {
    securityRules: subnet.nsgSecurityRules
  }
}]

//Set up the vnet (deploy if new deployment only)
resource VNet 'Microsoft.Network/virtualNetworks@2020-06-01' = if (newDeployment) {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetCidr
      ]
    }

    dhcpOptions: {
      dnsServers: dnsServers
    }
    //subnets pulled out into its own resource
    subnets: [for (subnet,i) in subnetList: {
      name: subnet.name
      properties: {
        networkSecurityGroup: subnet.nsgName != '' ? {
          location: location
          id: NSG[i].id
        } : {}
        addressPrefix: subnet.cidr
        privateEndpointNetworkPolicies: 'Disabled'
        delegations: subnet.delegation
        serviceEndpoints: serviceEndPoints
        routeTable: routeTableID != '' ? {
          id: routeTableID
        } : json('null')
      }
    }]
  }
}


//VNET Diagnostics
resource vnetDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: VNet
  name: '${vnetName}-diagnostics'
  properties: {
    workspaceId: lawID
    logs: [
      {
        category: 'VMProtectionAlerts'
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

//NSG Diagnostics
resource NSGDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview'  = [for (subnet,i) in subnetList: if (subnet.nsgName != '') {
  scope: NSG[i]
  name: '${subnet.nsgName}-diagnostics'
  properties: {
    workspaceId: lawID
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}]


output vnetID string = VNet.id
output vnetName string = VNet.name
output vnetCIDR string = vnetObject.vnetCidr

// output snetArray array = [for (subnet,i) in subnetList : {
//   name: VNet.properties.subnets[i].name
//   id: VNet.properties.subnets[i].id
//   // nsgID: VNet.properties.subnets[i].properties.networkSecurityGroup.id
//   // nsgName: VNet.properties.subnets[i].properties.networkSecurityGroup.name
//   // rtID: VNet.properties.subnets[i].properties.routeTable.id
//   // rtName: VNet.properties.subnets[i].properties.routeTable.name
// }]
