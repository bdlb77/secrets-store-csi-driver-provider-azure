#!/bin/bash
LAUNCHPATH=/go/src/secrets-store-csi-driver-provider-azure/
export $(cat $LAUNCHPATH/secrets.env | xargs)

SECRETS="{\"clientId\": \"$AZURE_CLIENT_ID\",\"clientSecret\": \"$AZURE_CLIENT_SECRET\"}"

ATTRIBUTES=$(cat $LAUNCHPATH/debug/parameters.yaml \
  | sed -e "s/{{KEYVAULT_NAME}}/$KEYVAULT_NAME/" \
  | sed -e "s/{{TENANT_ID}}/$TENANT_ID/" \
  | sed -e "s/{{OBJECT1_NAME}}/$OBJECT1_NAME/" \
  | sed -e "s/{{OBJECT1_ALIAS}}/$OBJECT1_ALIAS/" \
  | sed -e "s/{{OBJECT1_TYPE}}/$OBJECT1_TYPE/" \
  | sed -e "s/{{OBJECT1_VERSION}}/$OBJECT1_VERSION/" \
  | sed -e "s/{{OBJECT2_NAME}}/$OBJECT2_NAME/" \
  | sed -e "s/{{OBJECT2_ALIAS}}/$OBJECT2_ALIAS/" \
  | sed -e "s/{{OBJECT2_TYPE}}/$OBJECT2_TYPE/" \
  | sed -e "s/{{OBJECT2_VERSION}}/$OBJECT2_VERSION/" \
  | yq r - -j \
)

OBJECT_VERSIONS="[{\"objectName\": \"databasePassword\",\"objectVersion\": \"\"},{\"objectName\":\"storagePassword\", \"objectVersion\":\"123425\"}]"
export SECRETS=--secrets="$SECRETS"
export ATTRIBUTES=--attributes="$ATTRIBUTES"
export OBJECT_VERSIONS=--objectVersions="$OBJECT_VERSIONS"
jq -n '{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Application",
      "type": "go",
      "request": "launch",
      "mode": "exec",
      "program": "${workspaceFolder}/_output/secrets-store-csi-driver-provider-azure",
      "env":{},
      "args": [
        env.SECRETS,
        env.ATTRIBUTES,
        "--targetPath=/tmp/secrets",
        "--permission=420",
        env.OBJECT_VERSIONS,
        "--debug=true"
      ],
      "preLaunchTask": "create-tmp",
    }
  ]
}' > $LAUNCHPATH/.vscode/launch.json

make build
