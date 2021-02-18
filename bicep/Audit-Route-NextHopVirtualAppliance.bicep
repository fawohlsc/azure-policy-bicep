targetScope = 'subscription'
var policyName_var = 'Audit-Route-NextHopVirtualAppliance'
var policyDescription = 'Audit route tables for route with address prefix 0.0.0.0/0 pointing to the virtual appliance.'
var policyCategory = 'Network'
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
                allOf: [
                  {
                    field: 'Microsoft.Network/routeTables/routes[*].addressPrefix'
                    equals: '0.0.0.0/0'
                  }
                  {
                    field: 'Microsoft.Network/routeTables/routes[*].nextHopType'
                    equals: 'VirtualAppliance'
                  }
                  {
                    field: 'Microsoft.Network/routeTables/routes[*].nextHopIpAddress'
                    equals: '[parameters(\'routeTableSettings\')[field(\'location\')].virtualApplianceIpAddress]'
                  }
                ]
              }
            }
            equals: 0
          }
        ]
      }
      then: {
        effect: 'audit'
      }
    }
  }
}

resource Microsoft_Authorization_policyAssignments_policyName 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: uniqueString(policyName_var)
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
}