@description('O prefixo para todos os recursos, ex: "govlake".')
param prefix string = 'govlake'

@description('A localização para deploy dos recursos.')
param location string = 'eastus' // Você pode mudar para a região mais próxima de você

@description('Tags a serem aplicadas aos recursos.')
var tags = {
  project: prefix
  environment: 'dev'
}

// ------------------------------------------------------------------
// 1. O Resource Group (Grupo de Recursos)
// ------------------------------------------------------------------
targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-dev-001'
  location: location
  tags: tags
}

// ------------------------------------------------------------------
// 2. Módulos (Recursos dentro do Resource Group)
// ------------------------------------------------------------------

// Módulo para o Key Vault
module kv 'modules/keyvault.bicep' = {
  name: 'deploy-keyvault'
  scope: rg // Define o escopo para o Resource Group
  params: {
    location: location
    tags: tags
    keyVaultName: 'kv-${prefix}-dev-001'
  }
}

// Módulo para o Storage (ADLS Gen2)
module adls 'modules/adls.bicep' = {
  name: 'deploy-adls'
  scope: rg // Define o escopo para o Resource Group
  params: {
    location: location
    tags: tags
    storageAccountName: '${prefix}${uniqueString(rg.id)}'
  }
}

// ------------------------------------------------------------------
// 3. NOVO MÓDULO: Databricks Workspace
// ------------------------------------------------------------------
module dbw 'modules/databricks.bicep' = {
  name: 'deploy-databricks'
  scope: rg // Define o escopo para o Resource Group
  params: {
    location: location
    tags: tags
    databricksWorkspaceName: 'dbw-${prefix}-dev-001'
  } // <--- O 'params' FECHA AQUI

  // 'dependsOn' fica AQUI, no mesmo nível de 'name', 'scope' e 'params'
  // Garantimos que o Databricks só seja criado DEPOIS
  // que o ADLS e o Key Vault estiverem prontos.
  dependsOn: [
    kv
    adls
  ]
}
