#!/bin/bash

check_env_variable () {
if [ -z "$1" ]
 then
    echo "Environmental variable $2 is not set"
    echo "Source it first using command:"
    echo "source ~/.azure/kari-ss-vm-demo.sh"
    exit -1
fi
}

check_env_variable "$SS_VM_CLIENT_ID" "SS_VM_CLIENT_ID"
check_env_variable "$SS_VM_CLIENT_SECRET" "SS_VM_CLIENT_SECRET"
check_env_variable "$SS_VM_TENANT_ID" "SS_VM_TENANT_ID"
check_env_variable "$SS_VM_SUBSCRIPTION_ID" "SS_VM_SUBSCRIPTION_ID"

if [ $# -ne 2 ]
then
  echo "Usage: ./create-vm-image.sh <prefix> <main-resource-group>"
  echo "Example: ./create-vm-image kasri-ss-vm-demo"
  echo "NOTE: Use the following azure cli commands to check the right account and to login to az first:"
  echo "  az account list --output table                    => Check which Azure accounts you have."
  echo "  az account set -s \"<your-azure-account-name>\"     => Set the right azure account."
  echo "  az login                                          => Login to azure cli."
  echo "NOTE: Use the following terraform command to get the prefix and main resource group:"
  echo "  terraform output -module=env-def"
  exit 1
fi


MY_SS_VM_PREFIX=$1
MY_SS_VM_RG_NAME=$2
MY_SS_VM_IMAGE_NAME="${MY_SS_VM_PREFIX}-vm-image"


echo "Using prefix: $MY_SS_VM_PREFIX"

mkdir -p temp
MY_ORIG_DEPLOYMENT_FILENAME="ss-azure-vm-template.json"
MY_FINAL_DEPLOYMENT_FILENAME="temp/ss-azure-vm-final.json"

cp $MY_ORIG_DEPLOYMENT_FILENAME $MY_FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VM_CLIENT_ID/$SS_VM_CLIENT_ID/" $MY_FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VM_CLIENT_SECRET/$SS_VM_CLIENT_SECRET/" $MY_FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VM_TENANT_ID/$SS_VM_TENANT_ID/" $MY_FINAL_DEPLOYMENT_FILENAME
sed -i "s|REPLACE_SS_VM_SUBSCRIPTION_ID|$SS_VM_SUBSCRIPTION_ID|" $MY_FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VM_RG_NAME/$MY_SS_VM_RG_NAME/" $MY_FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VM_IMAGE_NAME/$MY_SS_VM_IMAGE_NAME/" $MY_FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VM_TAG_NAME/$MY_SS_VM_IMAGE_NAME/" $MY_FINAL_DEPLOYMENT_FILENAME

./create-tar.sh

# Just comment these lines out when debugging the script.
packer build $MY_FINAL_DEPLOYMENT_FILENAME
rm $MY_FINAL_DEPLOYMENT_FILENAME

rm app.tar.gz
