@description('O nome do Key Vault.')
param keyVaultName string

@description('A localização para o recurso.')
param location string

@description('Tags a serem aplicadas ao recurso.')
param tags object

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard' // SKU Standard é suficiente
    }
    tenantId: tenant().tenantId 
    enableRbacAuthorization: true 
  }
}
