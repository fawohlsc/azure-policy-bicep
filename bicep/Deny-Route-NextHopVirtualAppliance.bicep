targetScope = 'subscription'
var policyName_var = 'Deny-Route-NextHopVirtualAppliance'
var policyDescription = 'Deny route with address prefix 0.0.0.0/0 not pointing to the virtual appliance. Both creating routes as a standalone resource or nested within their parent resource route table are considered.'
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
        anyOf: [
          {
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
                        anyOf: [
                          {
                            field: 'Microsoft.Network/routeTables/routes[*].nextHopType'
                            notEquals: 'VirtualAppliance'
                          }
                          {
                            field: 'Microsoft.Network/routeTables/routes[*].nextHopIpAddress'
                            notEquals: '[parameters(\'routeTableSettings\')[field(\'location\')].virtualApplianceIpAddress]'
                          }
                        ]
                      }
                    ]
                  }
                }
                greater: 0
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Network/routeTables/routes'
              }
              {
                field: 'Microsoft.Network/routeTables/routes/addressPrefix'
                equals: '0.0.0.0/0'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.Network/routeTables/routes/nextHopType'
                    notEquals: 'VirtualAppliance'
                  }
                  {
                    field: 'Microsoft.Network/routeTables/routes/nextHopIpAddress'
                    notEquals: '[parameters(\'routeTableSettings\')[field(\'location\')].virtualApplianceIpAddress]'
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
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