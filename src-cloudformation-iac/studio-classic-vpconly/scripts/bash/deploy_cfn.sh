#!/bin/bash

# The first argument is the top-level directory path
TOP_LEVEL_DIR=$1

# The second argument is the specific folder where the CloudFormation templates and scripts are located
FOLDER=$2

# Source the AWS utilities script
source "${TOP_LEVEL_DIR}/scripts/bash/aws_utils.sh"

# Source the CloudFormation utilities script
source "${TOP_LEVEL_DIR}/scripts/bash/cfn_utils.sh"

# Construct the full path to the templates directory
TEMPLATES_DIR="${TOP_LEVEL_DIR}/src-cloudformation-iac/${FOLDER}/templates"

# Deploy the stacks using the functions from cfn_utils.sh
echo -e "Deploying StudioNetworkingPrereqs stack...\n"
deploy_stack "${TEMPLATES_DIR}/create-studio-networking-prereqs.yaml" "StudioNetworkingPrereqs"

echo -e "Deploying StudioAndUserInternetOnly stack...\n"
deploy_stack "${TEMPLATES_DIR}/create-studio-and-user-internet-only.yaml" "StudioAndUserInternetOnly" "StudioNetworkingPrereqs"
