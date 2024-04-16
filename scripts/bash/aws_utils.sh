#!/bin/bash

# Function to check and install AWS CLI
install_aws_cli() {
  if ! command -v aws &> /dev/null; then
      echo -e "AWS CLI not installed. Installing...\n"
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      echo -e "AWS CLI installed successfully.\n"
  else
      echo -e "AWS CLI is already installed.\n"
  fi
}

# Function to check for AWS credentials and prompt for them if not set
check_aws_credentials() {
  aws_access_key_id=$(aws configure get aws_access_key_id)
  aws_secret_access_key=$(aws configure get aws_secret_access_key)

  if [[ -z "$aws_access_key_id" || -z "$aws_secret_access_key" ]]; then
      echo -e "AWS credentials not set.\n"

      read -p "Enter your AWS Access Key ID: " user_access_key_id
      read -p "Enter your AWS Secret Access Key: " user_secret_access_key
      read -p "Enter your Default region name: " user_default_region
      read -p "Enter your Default output format [None|json|text|table]: " user_default_output

      aws configure set aws_access_key_id "$user_access_key_id"
      aws configure set aws_secret_access_key "$user_secret_access_key"
      aws configure set default.region "$user_default_region"
      aws configure set default.output "$user_default_output"
  else
      echo -e "Using existing AWS credentials.\n"
  fi
}

# Call the functions
install_aws_cli
check_aws_credentials
