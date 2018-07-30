#!/bin/bash
azure_service_principal_name=$1
azure_service_principal_key=$2
azure_storage_ad_tenant=$3
azure_storage_subscription=$4 
azure_storage_resource_group=$5
azure_storage_account_name=$6
azure_file_share_name=$7
namespace=$8
location=$9

echo "subscription: $azure_storage_subscription"
echo "namespace: $namespace"

az login --service-principal -u $azure_service_principal_name -p $azure_service_principal_key --tenant $azure_storage_ad_tenant
az account set --subscription $azure_storage_subscription

az storage account create --name $azure_storage_account_name --resource-group $azure_storage_resource_group --sku Standard_GRS --location $location

azure_storage_account_key=$(az storage account keys list -n $azure_storage_account_name -g $azure_storage_resource_group | jq '.[0].value' | sed 's/\"//g')

base64_name=`echo -n "$azure_storage_account_name" | base64 | tr -d '\n'`
base64_key=`echo -n "$azure_storage_account_key" | base64 | tr -d '\n'`
base64azurefileshare=`echo -n "$azure_file_share_name" | base64 | tr -d '\n'`

az storage share create -n $azure_file_share_name --account-key $azure_storage_account_key --account-name $azure_storage_account_name

KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)

cat > secret.json <<EOF
{    "apiVersion": "v1",    "data": {
       "azurestorageaccountname" : "$base64_name",
       "azurestorageaccountkey" : "$base64_key",
       "azurefileshare" : "$base64azurefileshare"
    },
    "kind": "Secret",
    "metadata": {
        "name": "storage-connection",
        "namespace": "$namespace"
    },
    "type": "Opaque"
}
EOF

cat secret.json

wget -S --header=Content-Type:application/json --no-check-certificate --ca-certificate /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --header "Authorization: Bearer $KUBE_TOKEN" --post-file secret.json "https://kubernetes.default:443/api/v1/namespaces/$namespace/secrets"
ret=$?
if [ $ret -ne 0 ]; then
        echo "secret exists, updating..."
        wget -S --header=Content-Type:application/json --no-check-certificate --ca-certificate /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --method PUT --header "Authorization: Bearer $KUBE_TOKEN" --body-file secret.json "https://kubernetes.default:443/api/v1/namespaces/$namespace/secrets/storage-connection"
        echo "secret updated"
else
        echo "secret created"
fi


