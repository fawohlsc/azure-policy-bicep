targetScope = 'managementGroup'
var roleDefinitionId = '/providers/microsoft.authorization/roleDefinitions/e0f68234-74aa-48ed-b826-c38b57376e17'

resource Deploy_Redis_FirewallRule 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'Deploy-Redis-FirewallRule'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Deploy-Redis-FirewallRule'
    description: 'Deploys Redis firewall rule.'
    metadata: {
      category: 'Cache'
    }
    parameters: {
      firewallRule: {
        type: 'Object'
        metadata: {
          displayName: 'Firewall Rule'
          description: 'The firewall rules to deploy.'
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Cache/Redis'
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Cache/Redis/firewallRules'
          roleDefinitionIds: [
            roleDefinitionId
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Cache/Redis/firewallRules/startIP'
                equals: '[parameters(\'firewallRule\').startIP]'
              }
              {
                field: 'Microsoft.Cache/Redis/firewallRules/endIP'
                equals: '[parameters(\'firewallRule\').endIP]'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                redisName: {
                  value: '[field(\'name\')]'
                }
                firewallRule: {
                  value: '[parameters(\'firewallRule\')]'
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  redisName: {
                    type: 'string'
                  }
                  firewallRule: {
                    type: 'Object'
                  }
                }
                resources: [
                  {
                    name: '[concat(parameters(\'redisName\'), \'/\', parameters(\'firewallRule\').name)]'
                    type: 'Microsoft.Cache/Redis/firewallRules'
                    apiVersion: '2019-07-01'
                    properties: {
                      startIP: '[parameters(\'firewallRule\').startIP]'
                      endIP: '[parameters(\'firewallRule\').endIP]'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}