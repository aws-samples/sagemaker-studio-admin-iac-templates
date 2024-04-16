// Existing Terraform src code found at /var/folders/xt/bwrhjh2s1ld30n8xcgngtmhm0000gr/T/terraform_src.

locals {
  stack_name = "MigrateSourceDomain"
}

variable source_domain_id {
  description = "The ID of the existing SageMaker Studio Domain."
  type = string
}

variable source_domain_region {
  description = "AWS Region for the SageMaker Studio Domain."
  type = string
}

variable lambda_admin_execution_role_arn {
  description = "ARN of the Lambda execution role to be used by Lambda to query source domain information."
  type = string
}

resource "aws_macie2_custom_data_identifier" "migrate_sage_maker_domain" {
  // CF Property(ServiceToken) = aws_lambda_function.sage_maker_migrate_lambda.arn
}

resource "aws_lambda_function" "sage_maker_migrate_lambda" {
  function_name = "${local.stack_name}-MigrateStudio"
  handler = "index.lambda_handler"
  role = var.lambda_admin_execution_role_arn
  runtime = "python3.12"
  memory_size = 128
  timeout = 180
  environment {
    variables = {
      SRC_DOMAIN_ID = var.source_domain_id
      SRC_REGION = var.source_domain_region
    }
  }
  code_signing_config_arn = {
    ZipFile = "# reference: https://stackoverflow.com/questions/53736963/aws-lambda-console-upgrade-boto3-version
import sys
from pip._internal import main

main(['install', '-I', '-q', 'boto3==1.34.54', '--target', '/tmp/', '--no-cache-dir', '--disable-pip-version-check'])
sys.path.insert(0,'/tmp/')

import boto3
from botocore.exceptions import ClientError

import os
import time
import json
import boto3
import cfnresponse

def lambda_handler(event, context):

    sagemaker_client = boto3.client('sagemaker')

    # Domain ID to describe
    domain_id = os.environ['SRC_DOMAIN_ID']

    print("event", event)
    print("context", context)
    print("domain_id", domain_id)

    # update domain
    domain_update = sagemaker_client.update_domain(
      DomainId=domain_id,
      DefaultUserSettings={
        'StudioWebPortal': 'ENABLED',
        'DefaultLandingUri': 'studio::'
      }
    )

    time.sleep(5)

    # Retrieve the domain details
    domain_response = sagemaker_client.describe_domain(DomainId=domain_id)

    try:

      domainParameters = {
          'UpdatedDomainId': domain_id,
          'StudioWebPortal': domain_response['DefaultUserSettings']['StudioWebPortal'],
          'DefaultLandingUri': domain_response['DefaultUserSettings']['DefaultLandingUri']
      }

      print("domainParameters", domainParameters)

      assert domainParameters['StudioWebPortal'] == 'ENABLED', f"Update failed {domainParameters}"

      cfnresponse.send(event, context, cfnresponse.SUCCESS, domainParameters, None)

    except Exception as e:

      domainParameters = {'Error': str(e)}
      cfnresponse.send(event, context, cfnresponse.FAILED, domainParameters, None)
"
  }
}

output "source_domain_id" {
  description = "Updated DomainId"
  value = aws_macie2_custom_data_identifier.migrate_sage_maker_domain.id
}

output "source_domain_web_portal_setting" {
  description = "Source Domain StudioWebPortal Setting"
  value = aws_macie2_custom_data_identifier.migrate_sage_maker_domain.tags
}

output "source_domain_default_landing_uri" {
  description = "Source Domain DefaultLandingUri Setting"
  value = aws_macie2_custom_data_identifier.migrate_sage_maker_domain.arn
}
