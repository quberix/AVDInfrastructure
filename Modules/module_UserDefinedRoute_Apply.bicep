//Associate a route table with one or more subnets

//Requires a udrSubnets object in the form - this is an extract of the subnet section from the larger standardised network object:
// [
//   {
//     name: 'subnet name'
//     cidr: 'x.x.x.x/x'
//   }]
//Note: Only the subnet name is actually required

@description('ID of the route table to apply')
param udrID string

@description('Name of the Vnet containing the subnets')
param vnetName string

@description('Array of subnets in prescribed format')
param udrSubnets array

//Apply to the list of subnets
@batchSize(1)
resource subnets 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = [for (subnet,i) in  udrSubnets: {
  name: '${vnetName}/${subnet.name}'
  properties: {
    routeTable: {
      id: udrID
    }
    addressPrefix: subnet.cidr
  }
}]
