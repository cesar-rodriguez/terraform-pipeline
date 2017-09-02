#!/bin/sh
#
# Produces terraform plan file.
#

set -e

# Get AWS credentials
mkdir -p ~/.aws
cp aws-creds/credentials ~/.aws/credentials

# "Building" terraform
errors=0
for env in $(ls infrastructure-repo/environments | grep '.tfvars' | cut -d '.' -f 1)
do
    echo "****************** BUILDING $env ******************"
    cp -R infrastructure-repo terraform-plan-out/$env
    cd terraform-plan-out/$env

    echo "BUILDING $env: terraform init"
    terraform init -input=false -backend-config=environments/$env.tf
    echo

    touch tfplan.txt
    set +e
    terraform plan -detailed-exitcode -out=tfplan -input=false -var-file=environments/$env.tfvars > tfplan.txt
    planexit=$?
    set -e
    if [ $planexit -eq 0 ]
    then
        echo "BUILDING $env: terraform plan <no changes>\n\n"
        cd ../
        rm -rf $env
        cd ../
        echo
        echo
    elif [ $planexit -eq 1 ]
    then
        echo "BUILDING $env: terraform plan <error>"
        cat tfplan.txt
        errors=1
        cd ../../
        echo
        echo
    else
        echo "BUILDING $env: terraform plan <diff>"
        cat tfplan.txt
        cd ../../
        echo
        echo
    fi
done

# The build fails if there are no changes in any environment
no_changes=$(ls terraform-plan-out | wc -l)
if [ $no_changes -eq 0 ]
then
    echo "There are no changes in any environment"
    exit 1
fi

if [ $errors -eq 0 ]
then
    # Tar built terraform plans
    tar -czf terraform-plan-$(cat version/number).tgz terraform-plan-out
    mv terraform-plan-$(cat version/number).tgz terraform-plan-out
    echo -e "BUILT terraform-plan-$(cat version/number).tgz"
    exit $errors
else
    exit $errors
fi

