//Takes the ID of an existing DNS service and registers a record against it.

//NOTE:  This module needs to be run correctly scoped rather than scoping in the module itself.  Due to inconsistencies in the API

@description('Type of DNS Record to add (matches entries in Common Config)')
param dnsResourceType string

@description('The DNS configuration from Common Config')
param dnsConfig object

@description('Name of the A record to add')
param recordName string

@description('IP address of the A record')
param recordIPAddress string

@description('Optional - Set the Time to Live (TTL) of the record.  Defaults to 3600 seconds')
param ttl int = 3600

//VARIABLES
//Get the DNS Register name and details
var privateDNSConfig = dnsConfig.privateDNSConfig[dnsResourceType]
var dnsRegisterName = privateDNSConfig.name


//Call the DNS register
resource dnsRegister 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: dnsRegisterName
}

//Add the A record
resource dnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: recordName
  parent: dnsRegister
  properties: {
    aRecords: [
      {
        ipv4Address: recordIPAddress
      }
    ]
    ttl: ttl
  }
}
