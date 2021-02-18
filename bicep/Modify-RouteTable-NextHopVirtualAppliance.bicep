targetScope = 'subscription'
var policyName_var = 'Modify-RouteTable-NextHopVirtualAppliance'
var policyDescription = 'Adds route with address prefix 0.0.0.0/0 pointing to the virtual appliance in case there is none. Best combined with policy deny-route-nexthopvirtualappliance to ensure the correct IP address of the virtual appliance.'
var policyCategory = 'Network'
var policyRoleDefinitionId = '/providers/microsoft.authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
var policyAssignmentName_var = uniqueString(policyName_var)
var policyAssignmentLocation = 'northeurope'
var policyAssignmentParameters = {
  routeTableSettings: {
    value: {
      northeurope: {
        virtualApplianceIpAddress: '10.0.0.23'
      }
      westeurope: {
        virtualApplianceIpAddress: '10.1.0.23'
      }
      disabled: {
        virtualApplianceIpAddress: ''
      }
    }
  }
}

resource policyName 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: policyName_var
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: policyName_var
    description: policyDescription
    metadata: {
      category: policyCategory
    }
    parameters: {
      routeTableSettings: {
        type: 'Object'
        metadata: {
          displayName: 'Route Table Settings'
          description: 'Location-specific settings for route tables.'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/routeTables'
          }
          {
            count: {
              field: 'Microsoft.Network/routeTables/routes[*]'
              where: {
                field: 'Microsoft.Network/routeTables/routes[*].addressPrefix'
                equals: '0.0.0.0/0'
              }
            }
            equals: 0
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            policyRoleDefinitionId
          ]
          conflictEffect: 'audit'
          operations: [
            {
              operation: 'add'
              field: 'Microsoft.Network/routeTables/routes[*]'
              value: {
                name: 'default'
                properties: {
                  addressPrefix: '0.0.0.0/0'
                  nextHopType: 'VirtualAppliance'
                  nextHopIpAddress: '[parameters(\'routeTableSettings\')[field(\'location\')].virtualApplianceIpAddress]'
                }
              }
            }
          ]
        }
      }
    }
  }
}

resource policyAssignmentName 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: policyAssignmentName_var
  properties: {
    displayName: policyName_var
    policyDefinitionId: policyName.id
    parameters: policyAssignmentParameters
    description: policyDescription
    metadata: {
      category: policyCategory
    }
    enforcementMode: 'Default'
  }
  location: policyAssignmentLocation
  identity: {
    type: 'SystemAssigned'
  }
}

resource Microsoft_Authorization_roleAssignments_policyAssignmentName 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentName_var)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: policyRoleDefinitionId
    principalId: reference(policyAssignmentName_var, '2020-03-01', 'Full').identity.principalId
  }
  dependsOn: [
    policyAssignmentName
  ]
}