// Existing Terraform src code found at /var/folders/xt/bwrhjh2s1ld30n8xcgngtmhm0000gr/T/terraform_src.

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  stack_name = "create-studio-and-mlopsengineer-vpc-only"
}

variable domain_name {
  description = "SageMaker Studio Domain Name"
  type = string
  default = "MyExampleDomain"
}

variable studio_user_name {
  description = "SageMaker Studio User Name"
  type = string
  default = "mlops-engineer"
}

variable ref_s3_bucket_ar_nfor_domain {
  description = "Default Bucket used by users in a domain have rw access to this bucket - format sagemaker-region-account-id"
  type = string
  default = "arn:aws:s3:::sagemaker-us-east-1-1234567890"
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

variable security_groups_ids {
  description = "Security Groups Ids for SageMaker Studio"
  type = string
  default = "sg-xxxxx or sg-1xxxx,sg-2xxxx,sg-3xxxx"
}

resource "aws_iam_role" "sage_maker_studio_ml_ops_role" {
  name = "${local.stack_name}-${var.domain_name}-MLOps-Role"
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
}

resource "aws_iam_policy" "sage_maker_mls3_access_policy" {
  name = "SageMaker_MLS3Access_Policy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          var.ref_s3_bucket_ar_nfor_domain
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          join("", [var.ref_s3_bucket_ar_nfor_domain, "/*"])
        ]
      }
    ]
  }
  // CF Property(Roles) = [
  //   aws_iam_role.sage_maker_studio_ml_ops_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_ml_experiment_viz_policy" {
  name = "SageMaker_MLExperimentViz_Policy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:DescribeAction",
          "sagemaker:DescribeArtifact",
          "sagemaker:DescribeContext",
          "sagemaker:DescribeExperiment",
          "sagemaker:DescribeTrial",
          "sagemaker:DescribeTrialComponent",
          "sagemaker:DescribeLineageGroup"
        ]
        Resource = "arn:aws:sagemaker:*:*:*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "sagemaker:ListAssociations",
          "sagemaker:ListActions",
          "sagemaker:ListArtifacts",
          "sagemaker:ListContexts",
          "sagemaker:ListExperiments",
          "sagemaker:ListTrials",
          "sagemaker:ListTrialComponents",
          "sagemaker:ListLineageGroups",
          "sagemaker:GetLineageGroupPolicy",
          "sagemaker:QueryLineage",
          "sagemaker:Search",
          "sagemaker:GetSearchSuggestions"
        ]
        Resource = "*"
      }
    ]
  }
  // CF Property(Roles) = [
  //   aws_iam_role.sage_maker_studio_ml_ops_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_ml_model_management_policy" {
  name = "SageMaker_MLModelManagement_Policy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:CreateModel",
          "sagemaker:CreateModelPackage",
          "sagemaker:CreateModelPackageGroup",
          "sagemaker:DescribeModel",
          "sagemaker:DescribeModelPackage",
          "sagemaker:DescribeModelPackageGroup",
          "sagemaker:BatchDescribeModelPackage",
          "sagemaker:UpdateModelPackage",
          "sagemaker:DeleteModel",
          "sagemaker:DeleteModelPackage",
          "sagemaker:DeleteModelPackageGroup"
        ]
        Resource = [
          "arn:aws:sagemaker:*:*:*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sagemaker:ListModels",
          "sagemaker:ListModelPackages",
          "sagemaker:ListModelPackageGroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.stack_name}-${var.domain_name}-MLOps-Role"
        ]
        Condition = {
          StringEquals = {
            iam:PassedToService = "sagemaker.amazonaws.com"
          }
        }
      }
    ]
  }
  // CF Property(Roles) = [
  //   aws_iam_role.sage_maker_studio_ml_ops_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_ml_ops_pipeline_policy" {
  name = "SageMaker_MLOpsPipeline_Policy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:CreatePipeline",
          "sagemaker:StartPipelineExecution",
          "sagemaker:StopPipelineExecution",
          "sagemaker:RetryPipelineExecution",
          "sagemaker:UpdatePipelineExecution",
          "sagemaker:SendPipelineExecutionStepSuccess",
          "sagemaker:SendPipelineExecutionStepFailure",
          "sagemaker:DescribePipeline",
          "sagemaker:DescribePipelineExecution",
          "sagemaker:DescribePipelineDefinitionForExecution",
          "sagemaker:DeletePipeline"
        ]
        Resource = [
          "arn:aws:sagemaker:*:*:*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sagemaker:ListPipelines",
          "sagemaker:ListPipelineExecutions",
          "sagemaker:ListPipelineExecutionSteps",
          "sagemaker:ListPipelineParametersForExecution"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.stack_name}-${var.domain_name}-MLOps-Role"
        ]
        Condition = {
          StringEquals = {
            iam:PassedToService = "sagemaker.amazonaws.com"
          }
        }
      }
    ]
  }
  // CF Property(Roles) = [
  //   aws_iam_role.sage_maker_studio_ml_ops_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_ml_endpoints_policy" {
  name = "SageMaker_MLEndpoints_Policy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:CreateEndpointConfig",
          "sagemaker:CreateEndpoint",
          "sagemaker:DeleteEndpointConfig",
          "sagemaker:DeleteEndpoint",
          "sagemaker:UpdateEndpoint",
          "sagemaker:UpdateEndpointWeightsAndCapacities",
          "sagemaker:DescribeEndpoint",
          "sagemaker:DescribeEndpointConfig"
        ]
        Resource = [
          "arn:aws:sagemaker:*:*:*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sagemaker:ListEndpoints",
          "sagemaker:ListEndpointConfigs"
        ]
        Resource = "*"
      }
    ]
  }
  // CF Property(Roles) = [
  //   aws_iam_role.sage_maker_studio_ml_ops_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_ml_studio_app_permission_policy" {
  name = "SageMaker_MLStudioAppPermission_Policy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SMStudioUserProfileAppPermissionsCreateAndDelete"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource = [
          "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/*"
        ]
        Condition = {
          Null = {
            sagemaker:OwnerUserProfileArn = "true"
          }
        }
      },
      {
        Sid = "SMStudioCreatePresignedDomainUrlForUserProfile"
        Effect = "Allow"
        Action = [
          "sagemaker:CreatePresignedDomainUrl"
        ]
        Resource = [
          join("", ["arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/", "${sagemaker:DomainId}/${sagemaker:UserProfileName}"])
        ]
      },
      {
        Sid = "SMStudioAppPermissionsListAndDescribe"
        Effect = "Allow"
        Action = [
          "sagemaker:ListApps",
          "sagemaker:ListDomains",
          "sagemaker:ListUserProfiles",
          "sagemaker:ListSpaces",
          "sagemaker:DescribeApp",
          "sagemaker:DescribeDomain",
          "sagemaker:DescribeUserProfile",
          "sagemaker:DescribeSpace"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid = "SMStudioAppPermissionsTagOnCreate"
        Effect = "Allow"
        Action = [
          "sagemaker:AddTags"
        ]
        Resource = [
          "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
        ]
        Condition = {
          Null = {
            sagemaker:TaggingAction = "false"
          }
        }
      },
      {
        Sid = "SMStudioRestrictSharedSpacesWithoutOwners"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ]
        Resource = [
          join("", ["arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:space/", "${sagemaker:DomainId}/*"])
        ]
        Condition = {
          Null = {
            sagemaker:OwnerUserProfileArn = "true"
          }
        }
      },
      {
        Sid = "SMStudioRestrictSpacesToOwnerUserProfile"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ]
        Resource = [
          join("", ["arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:space/", "${sagemaker:DomainId}/*"])
        ]
        Condition = {
          ArnLike = {
            sagemaker:OwnerUserProfileArn = [
              join("", ["arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/", "${sagemaker:DomainId}/*"])
            ]
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
        Sid = "SMStudioRestrictCreatePrivateSpaceAppsToOwnerUserProfile"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource = [
          join("", ["arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/", "${sagemaker:DomainId}/*"])
        ]
        Condition = {
          ArnLike = {
            sagemaker:OwnerUserProfileArn = [
              join("", ["arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/", "${sagemaker:DomainId}/${sagemaker:UserProfileName}"])
            ]
          }
          StringEquals = {
            sagemaker:SpaceSharingType = [
              "Private"
            ]
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
      }
    ]
  }
  // CF Property(Roles) = [
  //   aws_iam_role.sage_maker_studio_ml_ops_role.arn
  // ]
}

resource "aws_sagemaker_domain" "sage_maker_studio_vpc_only_domain" {
  app_network_access_type = "VpcOnly"
  auth_mode = "IAM"
  domain_name = var.domain_name
  subnet_ids = split("","", var.subnet_ids)
  vpc_id = var.vpc_id
  default_user_settings {
    security_groups = split("","", var.security_groups_ids)
    execution_role = aws_iam_role.sage_maker_studio_ml_ops_role.arn
  }
}

resource "aws_sagemaker_user_profile" "user_profile" {
  domain_id = aws_sagemaker_domain.sage_maker_studio_vpc_only_domain.arn
  user_profile_name = var.studio_user_name
  user_settings {
    execution_role = aws_iam_role.sage_maker_studio_ml_ops_role.arn
  }
}

output "new_sage_maker_domain" {
  description = "New Domain Id"
  value = aws_sagemaker_domain.sage_maker_studio_vpc_only_domain.arn
}

output "new_sage_maker_execution_role" {
  description = "SageMaker MLOps Role"
  value = aws_iam_role.sage_maker_studio_ml_ops_role.arn
}

output "sage_maker_domain_url" {
  description = "URL to access the SageMaker Domain"
  value = join("", ["https://console.aws.amazon.com/sagemaker/home?region=", data.aws_region.current.name, "#/studio/", aws_sagemaker_domain.sage_maker_studio_vpc_only_domain.arn])
}
