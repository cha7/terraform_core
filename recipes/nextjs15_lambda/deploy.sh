
#!/bin/bash

source ./.env

echo "Found REGION: ${REGION}"
echo "Found APP_NAME: ${APP_NAME}"
echo "Found APP_DESCRIPTION: ${APP_DESCRIPTION}"

rm -rf infra
mkdir infra
cp -r node_modules/terraform_core/modules ./infra
cp -r node_modules/terraform_core/recipes/nextjs15_lambda/* ./infra

cd infra
terraform init
terraform apply -var input_region=${REGION} -var application_name=${APP_NAME} -var application_description=${APP_DESCRIPTION} --auto-approve
