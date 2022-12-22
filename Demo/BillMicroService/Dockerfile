#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["BillMicroService/BillMicroService.csproj", "BillMicroService/"]
COPY ["SharedModelLibrary/SharedModelLibrary/SharedModelLibrary.csproj", "SharedModelLibrary/SharedModelLibrary/"]
RUN dotnet restore "BillMicroService/BillMicroService.csproj"
COPY . .
WORKDIR "/src/BillMicroService"
RUN dotnet build "BillMicroService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BillMicroService.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BillMicroService.dll"]