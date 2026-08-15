# Azure Pipelines Demo

Minimal ASP.NET Core MVC app for testing Azure Pipelines build artifacts and deployment to Azure App Service.

## Local Commands

```powershell
dotnet restore src/AzPipelinesDemo.csproj
dotnet build src/AzPipelinesDemo.csproj --configuration Release
dotnet publish src/AzPipelinesDemo.csproj --configuration Release --output publish
```

## Pipeline

`azure-pipelines.yml` restores, builds, tests, publishes code coverage, uploads the published app as a pipeline artifact named `drop`, and deploys the artifact to Azure App Service.

## Azure Deployment

The Bicep template uses the App Service `F1` Free tier for demo use. Free tier is intended for trials and learning, has quota limits, and is not suitable for production workloads.

Create the Azure resources with Azure CLI and Bicep:

```powershell
az login
az group create --name rg-az-pipelines-demo --location southeastasia
az deployment group create --resource-group rg-az-pipelines-demo --template-file infra/main.bicep
```

Create an Azure DevOps Azure Resource Manager service connection named `sc-az-pipelines-demo`, then run the pipeline from `master`.
