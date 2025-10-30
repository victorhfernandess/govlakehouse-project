@description('O nome do Workspace do Databricks.')
param databricksWorkspaceName string

@description('A localização para o recurso.')
param location string

@description('O SKU (tier) do Workspace. Premium é necessário para Unity Catalog e RBAC.')
@allowed([
  'standard'
  'premium'
  'trial'
])
param databricksSku string = 'premium'

@description('Tags a serem aplicadas ao recurso.')
param tags object

// Cria o Workspace do Azure Databricks
resource dbw 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: databricksWorkspaceName
  location: location
  tags: tags
  sku: {
    name: databricksSku
  }
  properties: {

    managedResourceGroupId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-databricks-managed-${databricksWorkspaceName}'
  }
}
