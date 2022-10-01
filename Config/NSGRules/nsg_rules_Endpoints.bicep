//If you want to set up private endpoints you will need to ensure that the subnet where the endpoint
//resides is both accessible (from a network perspective) and is secured with at least a default set of rules
//Remember - when you create a private endpoint you only have a single IP address associated with it which has
//to be added to a Private DNS server.

var pepHttpsService = [
  {
    name: 'AllowHttpsServicesInbound'
    properties: {
      description: 'Permit access to the PEP subnet for HTTPS services'
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
]

output pepHttpsInbound array = pepHttpsService
