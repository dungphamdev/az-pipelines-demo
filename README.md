# Azure Pipelines Demo

Minimal ASP.NET Core MVC app targeting .NET 10 for testing Azure Pipelines build artifacts and deployment to Azure App Service.

## Local Commands

The app uses SQL Server for the Products CRUD demo. On Windows, the development connection string uses SQL Server LocalDB:

```json
"DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Database=AzPipelinesDemo;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"
```

Check LocalDB is available:

```powershell
sqllocaldb info
```

Run the app locally:

```powershell
dotnet restore src/AzPipelinesDemo.csproj
dotnet build src/AzPipelinesDemo.csproj --configuration Release
dotnet run --project src/AzPipelinesDemo.csproj
dotnet publish src/AzPipelinesDemo.csproj --configuration Release --output publish
```

Open the local URL shown by `dotnet run`, then go to `/Products`. The database is created automatically on first startup.

Entity Framework migrations are applied automatically on app startup. To add a future migration after changing models:

```powershell
dotnet tool install --global dotnet-ef
dotnet ef migrations add MigrationName --project src/AzPipelinesDemo.csproj
```

## Pipeline

`azure-pipelines.yml` restores, builds, tests, publishes code coverage, uploads the published app as a pipeline artifact named `drop`, and deploys the artifact to Azure App Service.

## Azure Deployment

The Bicep template uses the App Service `F1` Free tier for demo use. Free tier is intended for trials and learning, has quota limits, and is not suitable for production workloads.

Create the Azure resources with Azure CLI and Bicep:

```powershell
az login
az group create --name rg-az-pipelines-demo --location southeastasia
az deployment group create --resource-group rg-az-pipelines-demo --template-file infra/main.bicep --parameters sqlAdministratorPassword="<your-strong-password>"
```

Create an Azure DevOps Azure Resource Manager service connection named `sc-az-pipelines-demo`, then run the pipeline from `master`.

Delete all demo Azure resources when finished:

```powershell
az group delete --name rg-az-pipelines-demo
```
