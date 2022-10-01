//Defines the NSG rules for a typical VM based Ad server

var adSnetStandardInboundRules = [
  {
    name: 'AllowRPCEndpointMapper'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '135'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowLDAP'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRanges: [
        '389'
        '636'
      ]
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 130
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowGlobalCatalogue'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '3268'
        '3269'
      ]
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 140
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowKerberos'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRanges: [
        '88'
        '464'
      ]
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 150
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowDNS'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '53'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 160
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowSMB'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '445'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 170
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowW32Time'
    properties: {
      protocol: 'UDP'
      sourcePortRange: '*'
      destinationPortRange: '123'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 180
      direction: 'Inbound'
    }
  }
]

output inbound array = adSnetStandardInboundRules
