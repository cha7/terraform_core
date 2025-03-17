
#!/bin/bash

source ./.env.infra

if [[ -z $1 ]] 
then
tfcommand="apply"
elif [[ $1 != "apply" && $1 != "destroy" ]]
then
echo "TF command only supports 'apply' and 'destroy'"
exit 1
else
tfcommand=$1
fi

awsAccountId=$(aws sts get-caller-identity --query Account --output text)

echo "Found REGION: ${REGION}"
echo "Found APP_NAME: ${APP_NAME}"
echo "Found APP_DESCRIPTION: ${APP_DESCRIPTION}"

rm -rf infra
mkdir infra
cp -r node_modules/terraform_core/modules ./infra
cp -r node_modules/terraform_core/recipes/nextjs15_lambda/* ./infra

cd infra

terraform init \
-backend-config="bucket=terraform-${awsAccountId}-us-east-1" \
-backend-config="key=${APP_NAME}/${REGION}" \
-backend-config="region=${REGION}"

terraform ${tfcommand} -var input_region=${REGION} \
-var input_application_name=${APP_NAME} \
-var input_application_description=${APP_DESCRIPTION} --auto-approve
