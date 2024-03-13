// Existing Terraform src code found at /var/folders/xt/bwrhjh2s1ld30n8xcgngtmhm0000gr/T/terraform_src.

locals {
  stack_name = "CreateTestDomainFromSourceDomain"
}

variable source_domain_id {
  description = "The ID of the existing SageMaker Studio Domain."
  type = string
}

variable source_domain_region {
  description = "AWS Region for the SageMaker Studio Domain."
  type = string
}

variable target_domain_name {
  description = "Name of target domain to be created by IaC"
  type = string
}

variable target_domain_user {
  description = "Name of test user under test domain to be created by IaC"
  type = string
  default = "test-user"
}

resource "aws_macie2_custom_data_identifier" "source_sage_maker_domain" {
  // CF Property(ServiceToken) = aws_lambda_function.sage_maker_query_lambda.arn
}

resource "aws_iam_role" "sage_maker_query_lambda_role" {
  name = "${local.stack_name}-LambdaExecRole"
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  }
  path = "/"
  force_detach_policies = [
    {
      PolicyName = "${local.stack_name}-LambdaExecPolicy"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "sagemaker:DescribeDomain"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            Resource = "*"
          }
        ]
      }
    }
  ]
}

resource "aws_lambda_function" "sage_maker_query_lambda" {
  function_name = "${local.stack_name}-QuerySageMaker"
  handler = "index.lambda_handler"
  role = aws_iam_role.sage_maker_query_lambda_role.arn
  runtime = "python3.11"
  memory_size = 128
  timeout = 30
  environment {
    variables = {
      SRC_DOMAIN_ID = var.source_domain_id
      SRC_REGION = var.source_domain_region
    }
  }
  code_signing_config_arn = {
    ZipFile = "import os
import json
import boto3
import cfnresponse

def lambda_handler(event, context):
    # Initialize the SageMaker and CloudFormation clients
    sagemaker_client = boto3.client('sagemaker')

    # Domain ID to describe
    domain_id = os.environ['SRC_DOMAIN_ID']

    print("event", event)
    print("context", context)
    print("domain_id", domain_id)

    # Retrieve the domain details
    domain_response = sagemaker_client.describe_domain(DomainId=domain_id)

    try:

      domainParameters = {
          'AppNetworkAccessType': domain_response['AppNetworkAccessType'],
          'AuthMode': domain_response['AuthMode'],
          'VpcId': domain_response['VpcId'],
          'SubnetIds': ",".join(domain_response['SubnetIds']),
          'ExecutionRole': domain_response['DefaultUserSettings']['ExecutionRole'],
          'SecurityGroups': ",".join(domain_response['DefaultUserSettings']['SecurityGroups'])
      }
      
      print("domainParameters", domainParameters)

      cfnresponse.send(event, context, cfnresponse.SUCCESS, domainParameters, None)

    except Exception as e:

      domainParameters = {'Error': str(e)}
      cfnresponse.send(event, context, cfnresponse.FAILED, domainParameters, None)
"
  }
}

resource "aws_sagemaker_domain" "create_target_studio_domain" {
  domain_name = var.target_domain_name
  // Unable to resolve Fn::GetAtt with value: [
  //   "SourceSageMakerDomain",
  //   "AppNetworkAccessType"
  // ]
  auth_mode = aws_macie2_custom_data_identifier.source_sage_maker_domain.name
  vpc_id = aws_macie2_custom_data_identifier.source_sage_maker_domain.id
  subnet_ids = split("","", aws_macie2_custom_data_identifier.source_sage_maker_domain.id)
  default_user_settings {
    execution_role = aws_macie2_custom_data_identifier.source_sage_maker_domain.regex
    studio_web_portal = "ENABLED"
    default_landing_uri = "studio::"
    security_groups = split("","", // Unable to resolve Fn::GetAtt with value: [
//   "SourceSageMakerDomain",
//   "SecurityGroups"
// ])
  }
}

resource "aws_sagemaker_user_profile" "studio_user_profile" {
  domain_id = aws_sagemaker_domain.create_target_studio_domain.arn
  user_profile_name = var.target_domain_user
  user_settings {
    execution_role = aws_macie2_custom_data_identifier.source_sage_maker_domain.regex
  }
}

resource "aws_iam_policy" "update_role_with_v2_sage_maker_policy" {
  name = "SageMakerV2SpaceAndAppAccessPolicy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowStudioActions"
        Effect = "Allow"
        Action = [
          "sagemaker:CreatePresignedDomainUrl",
          "sagemaker:DescribeDomain",
          "sagemaker:ListDomains",
          "sagemaker:DescribeUserProfile",
          "sagemaker:ListUserProfiles",
          "sagemaker:DescribeSpace",
          "sagemaker:ListSpaces",
          "sagemaker:DescribeApp",
          "sagemaker:ListApps"
        ]
        Resource = "*"
      },
      {
        Sid = "AllowAppActionsForUserProfile"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource = "arn:aws:sagemaker:*:*:app/*/*/*/*"
        Condition = {
          Null = {
            sagemaker:OwnerUserProfileArn = "true"
          }
        }
      },
      {
        Sid = "AllowAppActionsForSharedSpaces"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource = "arn:aws:sagemaker:*:*:app/${sagemaker:DomainId}/*/*/*"
        Condition = {
          StringEquals = {
            sagemaker:SpaceSharingType = [
              "Shared"
            ]
          }
        }
      },
      {
        Sid = "AllowMutatingActionsOnSharedSpacesWithoutOwner"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ]
        Resource = "arn:aws:sagemaker:*:*:space/${sagemaker:DomainId}/*"
        Condition = {
          Null = {
            sagemaker:OwnerUserProfileArn = "true"
          }
        }
      },
      {
        Sid = "RestrictMutatingActionsOnSpacesToOwnerUserProfile"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ]
        Resource = "arn:aws:sagemaker:*:*:space/${sagemaker:DomainId}/*"
        Condition = {
          ArnLike = {
            sagemaker:OwnerUserProfileArn = "arn:aws:sagemaker:*:*:user-profile/${sagemaker:DomainId}/${sagemaker:UserProfileName}"
          }
          StringEquals = {
            sagemaker:SpaceSharingType = [
              "Private",
              "Shared"
            ]
          }
        }
      },
      {
        Sid = "RestrictMutatingActionsOnPrivateSpaceAppsToOwnerUserProfile"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource = "arn:aws:sagemaker:*:*:app/${sagemaker:DomainId}/*/*/*"
        Condition = {
          ArnLike = {
            sagemaker:OwnerUserProfileArn = "arn:aws:sagemaker:*:*:user-profile/${sagemaker:DomainId}/${sagemaker:UserProfileName}"
          }
          StringEquals = {
            sagemaker:SpaceSharingType = [
              "Private"
            ]
          }
        }
      }
    ]
  }
  // CF Property(Roles) = [
  //   element(split(""/"", aws_macie2_custom_data_identifier.source_sage_maker_domain.regex), 1)
  // ]
}

output "source_domain_auth_mode" {
  description = "Source AuthMode"
  value = aws_macie2_custom_data_identifier.source_sage_maker_domain.name
}

output "source_domain_vpc" {
  description = "Source VpcId"
  value = aws_macie2_custom_data_identifier.source_sage_maker_domain.id
}

output "source_domain_subnet_ids" {
  description = "Source SubnetIds"
  value = aws_macie2_custom_data_identifier.source_sage_maker_domain.id
}

output "source_domain_execution_role" {
  description = "Source ExecutionRole"
  value = aws_macie2_custom_data_identifier.source_sage_maker_domain.regex
}

output "source_domain_security_groups" {
  description = "Source SecurityGroups"
  // Unable to resolve Fn::GetAtt with value: [
  //   "SourceSageMakerDomain",
  //   "SecurityGroups"
  // ]
}

output "target_domain_id" {
  description = "Target DomainId"
  value = aws_sagemaker_domain.create_target_studio_domain.arn
}

output "target_domain_url" {
  description = "Target Domain URL"
  value = aws_sagemaker_domain.create_target_studio_domain.url
}

output "updated_sage_maker_policy" {
  description = "SageMaker Updated Policy"
  value = aws_iam_policy.update_role_with_v2_sage_maker_policy.id
}
