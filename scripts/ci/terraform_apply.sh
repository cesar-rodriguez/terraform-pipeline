#!/bin/sh
#
# Performs terraform apply
#

set -e

if [ ! -z ${DEBUG_MODE} ]
then
  if [ ${DEBUG_MODE} = "true" ]
  then
    echo "DEBUG MODE"
    set -x
  fi
fi

# Get AWS credentials
mkdir -p ~/.aws
cp aws-creds/credentials ~/.aws/credentials

# Provisioning infrastructure
tar -xzf artifacts/${BUILD_PIPELINE_NAME}-$(cat version/number).tgz
for env in $(ls terraform-plan-out)
do
    echo "****************** PROVISIONING $env ******************"
    set -x
    cd terraform-plan-out/$env
    cat tfplan.txt
    terraform apply -input=false tfplan
    set +x
    cd ../../
done

echo "v$(cat version/number)" > release/tag
echo "terraform-pipeline v$(cat version/number)" > release/name
