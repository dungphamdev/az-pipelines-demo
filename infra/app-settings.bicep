@description('The Web App name that receives these application settings.')
param webAppName string

@description('Application settings exposed to the app as environment variables.')
param appSettings object = {
  ASPNETCORE_ENVIRONMENT: 'Production'
  FeatureFlags__Products: 'true'
}

resource webApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webAppName
}

resource webAppAppSettings 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'appsettings'
  properties: appSettings
}
