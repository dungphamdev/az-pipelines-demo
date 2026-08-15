FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY src/AzPipelinesDemo.csproj src/
RUN dotnet restore src/AzPipelinesDemo.csproj

COPY . .
RUN dotnet publish src/AzPipelinesDemo.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "AzPipelinesDemo.dll"]
