@description('O nome do Storage Account (deve ser globalmente único).')
param storageAccountName string

@description('A localização para o recurso.')
param location string

@description('Tags a serem aplicadas ao recurso.')
param tags object

// Define os 4 containers que queremos criar
var containerNames = [
  'raw'
  'bronze'
  'silver'
  'gold'
]

// 1. Cria o Storage Account (habilitado para ADLS Gen2)
resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2' // Kind V2 é necessário para ADLS
  sku: {
    name: 'Standard_LRS' // LRS é o mais barato e suficiente para dev
  }
  properties: {
    isHnsEnabled: true // <--- ISSO HABILITA O ADLS Gen2 (Hierarchical Namespace)
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// 2. Define o Blob Service (necessário para criar containers)
// Este é o 'default' blob service que existe em qualquer storage account
resource bs 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: st // Define o parent como o storage account 'st'
  name: 'default' // O nome é sempre 'default'
}

// 3. Cria os containers (loop)
// Agora, o parent é o resource 'bs' (blob service)
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [for (containerName, i) in containerNames: {
  parent: bs // <--- ESTA É A CORREÇÃO
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}]
