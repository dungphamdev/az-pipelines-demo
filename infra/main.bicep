@description('Azure region for all resources.')
param location string = 'southeastasia'

@description('Resource name prefix.')
param namePrefix string = 'az-pipelines-demo'

@description('SQL administrator username.')
param sqlAdministratorLogin string = 'sqladminuser'

@secure()
@description('SQL administrator password.')
param sqlAdministratorPassword string

var appServicePlanName = 'asp-${namePrefix}'
var webAppName = 'app-${namePrefix}'
var keyVaultName = 'kv-${uniqueString(resourceGroup().id, namePrefix)}'
var sqlServerName = 'sql-${namePrefix}-${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'sqldb-${namePrefix}'
var defaultConnectionSecretName = 'DefaultConnection'
var defaultConnection = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|10.0'
      alwaysOn: false
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: webApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    maxSizeBytes: 2147483648
  }
}

resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource defaultConnectionSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: defaultConnectionSecretName
  properties: {
    value: defaultConnection
  }
}

resource webAppConnectionStrings 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'connectionstrings'
  properties: {
    DefaultConnection: {
      value: '@Microsoft.KeyVault(SecretUri=${defaultConnectionSecret.properties.secretUri})'
      type: 'SQLAzure'
    }
  }
}

module webAppAppSettings 'app-settings.bicep' = {
  name: 'web-app-app-settings'
  params: {
    webAppName: webApp.name
  }
}

output webAppName string = webApp.name
output defaultHostName string = webApp.properties.defaultHostName
output keyVaultName string = keyVault.name
output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name
