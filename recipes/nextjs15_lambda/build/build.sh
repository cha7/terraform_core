#!/bin/bash
cp -r public/. .next/standalone/public
cp -r .next/static/. .next/standalone/.next/static
cp node_modules/terraform_core/recipes/nextjs15_lambda/handler/run.sh .next/standalone/run.sh

rm -f ./lambda.zip && (cd .next/standalone/ && zip -r ../../lambda.zip .)