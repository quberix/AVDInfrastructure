//Retrieves the correct Log Analytics Workspace and returns it as an ID

@description('Config object containing the details of the LAW instances available')
param diagLAWObject object

@description('The LAW environment to use')
param diagLAWEnv string

@description('The type of LAW to use (based on the LAW types in the config)')
param diagLAWType string

//VARIABLES
var envData = diagLAWObject[diagLAWEnv]
var lawData = envData[diagLAWType]
var lawName = lawData.name
var diagRG = lawData.rg
var diagSub = lawData.subscription

//Get the log analytics workspace
resource diagLogAnalyticsDiagnostics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: lawName
  scope: resourceGroup(diagSub,diagRG)
}

output diagLogAnalyticsID string = diagLogAnalyticsDiagnostics.id
output diagLogAnalyticsName string = diagLogAnalyticsDiagnostics.name
output diagLogAnalyticsCustomerID string = diagLogAnalyticsDiagnostics.properties.customerId
