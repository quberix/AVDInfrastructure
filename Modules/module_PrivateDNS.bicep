//Deploy a Private DNS Zone
@description('Tags for the deployed resources')
param tags object

//there is no location for private dns as they are all "global"

@description('Object of Private DNS Zones to create')
param privateDNSList object

resource PrivateDNSEntries 'Microsoft.Network/privateDnsZones@2020-06-01' = [ for pDNSName in items(privateDNSList) : {
  name: pDNSName.value.name
  location: 'global'
  tags: tags
}]



