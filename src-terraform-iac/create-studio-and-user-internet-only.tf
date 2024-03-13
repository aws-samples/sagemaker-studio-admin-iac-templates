// Existing Terraform src code found at /var/folders/xt/bwrhjh2s1ld30n8xcgngtmhm0000gr/T/terraform_src.

data "aws_region" "current" {}

locals {
  stack_name = "create-studio-and-user-internet-only"
}

variable domain_name {
  description = "SageMaker Studio Domain Name"
  type = string
  default = "MyExampleDomain"
}

variable studio_user_name {
  description = "SageMaker Studio User Name"
  type = string
  default = "test-user1"
}

variable vpc_id {
  description = "VPC Id for SageMaker Studio"
  type = string
  default = "vpc-xxxxxx"
}

variable subnet_ids {
  description = "Subnet Ids for SageMaker Studio"
  type = string
  default = "subnet-xxxxx or subnet-1xxxx,subnet-2xxxx,subnet-3xxxx"
}

resource "aws_iam_role" "sage_maker_studio_full_access_role" {
  name = "${local.stack_name}-${var.domain_name}-Role"
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "sagemaker.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  path = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  ]
}

resource "aws_sagemaker_domain" "sage_maker_studio_internet_only_domain" {
  app_network_access_type = "PublicInternetOnly"
  auth_mode = "IAM"
  domain_name = var.domain_name
  subnet_ids = split("","", var.subnet_ids)
  vpc_id = var.vpc_id
  default_user_settings {
    security_groups = [
    ]
    execution_role = aws_iam_role.sage_maker_studio_full_access_role.arn
  }
}

resource "aws_sagemaker_user_profile" "user_profile" {
  domain_id = aws_sagemaker_domain.sage_maker_studio_internet_only_domain.arn
  user_profile_name = var.studio_user_name
  user_settings {
    execution_role = aws_iam_role.sage_maker_studio_full_access_role.arn
  }
}

output "new_sage_maker_domain" {
  description = "New Domain Id"
  value = aws_sagemaker_domain.sage_maker_studio_internet_only_domain.arn
}

output "sage_maker_domain_url" {
  description = "URL to access the SageMaker Domain"
  value = join("", ["https://console.aws.amazon.com/sagemaker/home?region=", data.aws_region.current.name, "#/studio/", aws_sagemaker_domain.sage_maker_studio_internet_only_domain.arn])
}
