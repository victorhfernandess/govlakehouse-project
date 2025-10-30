@description('O nome do Key Vault.')
param keyVaultName string

@description('A localização para o recurso.')
param location string

@description('Tags a serem aplicadas ao recurso.')
param tags object

// NOTA: Em um projeto real, configuraríamos o 'accessPolicies'
// para permitir que o Databricks ou o seu usuário acesse o cofre.
// Por enquanto, apenas criaremos o cofre.
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard' // SKU Standard é suficiente
    }
    tenantId: tenant().tenantId // Pega o ID do seu "inquilino" (sua conta)
    enableRbacAuthorization: true // Usar RBAC é a prática moderna (em vez de Access Policies)
  }
}
