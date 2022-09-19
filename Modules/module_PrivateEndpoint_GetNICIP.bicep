//Gets the IP address of an existing NIC

param nicName string

//Get the NIC
resource pepNIC 'Microsoft.Network/networkInterfaces@2021-03-01' existing = {
  name: nicName
}

output nicIP string = pepNIC.properties.ipConfigurations[0].properties.privateIPAddress
