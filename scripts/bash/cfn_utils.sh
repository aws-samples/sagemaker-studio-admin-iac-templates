#!/bin/bash

# Function to check if a CloudFormation stack exists
stack_exists() {
    local stack_name="$1"
    local stack_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
    [[ -n $stack_status ]]
}

# Function to deploy a CloudFormation stack if it doesn't already exist
deploy_stack() {
    template_file=$1
    stack_name=$2
    depends_on_stack=$3

    # Check if the stack already exists
    if stack_exists "$stack_name"; then
        echo -e "Stack '$stack_name' already exists. Skipping deployment.\n"
    else
        echo "Deploying stack: '$stack_name' "
        # If the stack depends on another stack, get the output from that stack
        if [[ -n $depends_on_stack ]]; then
            aws cloudformation deploy \
                --template-file "$template_file" \
                --stack-name "$stack_name" \
                --parameter-overrides CoreNetworkingStackName="$depends_on_stack" \
                --capabilities CAPABILITY_NAMED_IAM \
                --no-fail-on-empty-changeset
        else
            # If the stack doesn't depend on another stack, deploy without passing any parameters
            aws cloudformation deploy \
                --template-file "$template_file" \
                --stack-name "$stack_name" \
                --capabilities CAPABILITY_NAMED_IAM \
                --no-fail-on-empty-changeset
        fi
        echo -e "Deployment of $stack_name completed.\n"
    fi
}

# Function to delete a CloudFormation stack
delete_stack() {
    stack_name=$1
    region=$2

    echo "Attempting to delete stack: $stack_name"
    if aws cloudformation describe-stacks --region "$region" --stack-name "$stack_name" &> /dev/null; then
        echo -e "Stack $stack_name exists in region $region. Deleting...\n"
        aws cloudformation delete-stack --region "$region" --stack-name "$stack_name"
        echo "Delete request sent for stack: $stack_name. Waiting for stack to be deleted..."
        aws cloudformation wait stack-delete-complete --region "$region" --stack-name "$stack_name"
        echo "Stack $stack_name deleted successfully."
    else
        echo -e "Stack $stack_name does not exist in region $region.\n"
    fi
}

