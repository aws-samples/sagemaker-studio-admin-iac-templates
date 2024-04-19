#!/bin/bash

# The first argument is the top-level directory path
TOP_LEVEL_DIR=$1

# The second argument is the specific folder where the CloudFormation templates and scripts are located
FOLDER=$2

# The third argument is the Studio ARN that we've
STUDIO_ARN=$3

# Source the AWS utilities script for AWS CLI checks and credential configuration
source "${TOP_LEVEL_DIR}/scripts/bash/aws_utils.sh"

# Source the CloudFormation utilities script for stack deletion
source "${TOP_LEVEL_DIR}/scripts/bash/cfn_utils.sh"

# Python script for cleanup
PYTHON_SCRIPT="${TOP_LEVEL_DIR}/src-cloudformation-iac/${FOLDER}/scripts/python/cleanup.py"

# Requirements file for Python dependencies
REQUIREMENTS_FILE="${TOP_LEVEL_DIR}/src-cloudformation-iac/${FOLDER}/requirements.txt"

# Read the region from AWS configuration or prompt for it
region=$(aws configure get region)
if [[ -z "$region" ]]; then
    read -p "Enter the AWS region where the stacks were deployed: " region
fi

# Install Python dependencies
echo -e "Installing Python dependencies...\n"
python3 -m pip install --upgrade pip
python3 -m pip install --user -r "$REQUIREMENTS_FILE"

# Delete StudioAndUserInternetOnly stack
echo -e "Deleting StudioAndUserInternetOnly stack...\n"
delete_stack "StudioAndUserInternetOnly" "$region"

# Run Python script for cleanup
echo -e "Running Python script for cleanup...\n"
python3 "$PYTHON_SCRIPT" --sagemaker-studio-domain "$STUDIO_ARN"

# Delete StudioNetworkingPrereqs stack
echo -e "Deleting StudioNetworkingPrereqs stack...\n"
delete_stack "StudioNetworkingPrereqs" "$region"
