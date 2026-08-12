# Azure Pipelines Demo

Minimal ASP.NET Core MVC app for testing Azure Pipelines build artifacts and deployment to Azure App Service.

## Local Commands

```powershell
dotnet restore src/AzPipelinesDemo.csproj
dotnet build src/AzPipelinesDemo.csproj --configuration Release
dotnet publish src/AzPipelinesDemo.csproj --configuration Release --output publish
```

## Pipeline

`azure-pipelines.yml` restores, builds, publishes, and uploads the published app as a build artifact named `drop`.

Add an Azure App Service deploy task or a release pipeline after the artifact is created.
