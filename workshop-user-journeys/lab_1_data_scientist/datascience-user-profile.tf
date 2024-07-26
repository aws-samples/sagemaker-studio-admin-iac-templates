provider "aws" {
  region = "us-east-1" 
}

variable "SageMakerDomainId" {
  description = "Domain ID of the Source SageMaker Studio Domain - run aws sagemaker describe-domain --domain-id..."
}

variable "SageMakerCloudformationSubnetId" {
  description = "Subnet Id of the source SageMaker Studio Domain"
}

variable "SageMakerCloudformationSecurityGroup" {
  description = "Security Group Id of the source SageMaker Studio Domain"
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

variable "data_science_user_profile_name" {
  description = "The name of the new UserProfile"
  type        = string
  default     = "data-science"
}

resource "aws_iam_role" "data_science_sage_maker_execution_role" {
  name               = "AmazonSageMakerExecutionRole-${var.data_science_user_profile_name}-${data.aws_region.current.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSageMakerFeatureStoreAccess"
  ]

  inline_policy {
    name   = "iam_pass_role"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "iam:PassRole"
          Resource = [
            format("arn:aws:iam::%s:role/service-role/AmazonSageMakerExecutionRole-%s-%s", data.aws_caller_identity.current.account_id, var.data_science_user_profile_name, data.aws_region.current.name),
            format("arn:aws:iam::%s:role/AmazonSageMakerExecutionRole-%s-%s", data.aws_caller_identity.current.account_id, var.data_science_user_profile_name, data.aws_region.current.name)
          ]
          Condition = {
            StringEquals = {
              "iam:PassedToService" = "sagemaker.amazonaws.com"
            }
          }
        }
      ]
    })
  }

  inline_policy {
    name   = "s3_access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"
          ]
          Resource = "arn:aws:s3:::*"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker_common_job_management"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sagemaker:CreateTrainingJob",
            "sagemaker:CreateTransformJob",
            "sagemaker:CreateProcessingJob",
            "sagemaker:CreateAutoMLJob",
            "sagemaker:CreateHyperParameterTuningJob",
            "sagemaker:UpdateTrainingJob"
          ]
          Resource = "arn:aws:sagemaker:*:*:*/*"
          Condition = {
            "ForAllValues:StringEquals" = {
              "sagemaker:VpcSecurityGroupIds" = [var.SageMakerCloudformationSecurityGroup],
              "sagemaker:VpcSubnets"          = [var.SageMakerCloudformationSubnetId]
            }
            Null = {
              "sagemaker:VpcSubnets"         = false,
              "sagemaker:VpcSecurityGroupIds" = false
            }
          }
        },
        {
          Effect = "Allow"
          Action = [
            "sagemaker:StopTrainingJob",
            "sagemaker:StopProcessingJob",
            "sagemaker:StopAutoMLJob",
            "sagemaker:StopHyperParameterTuningJob",
            "sagemaker:DescribeTrainingJob",
            "sagemaker:DescribeTransformJob",
            "sagemaker:DescribeProcessingJob",
            "sagemaker:DescribeAutoMLJob",
            "sagemaker:DescribeHyperParameterTuningJob",
            "sagemaker:BatchGetMetrics"
          ]
          Resource = "arn:aws:sagemaker:*:*:*/*"
        },
        {
          Effect = "Allow"
          Action = [
            "sagemaker:Search",
            "sagemaker:ListTrainingJobs",
            "sagemaker:ListTransformJobs",
            "sagemaker:ListProcessingJobs",
            "sagemaker:ListAutoMLJobs",
            "sagemaker:ListCandidatesForAutoMLJob",
            "sagemaker:ListHyperParameterTuningJobs",
            "sagemaker:ListTrainingJobsForHyperParameterTuningJob",
            "sagemaker:ListFeatureGroups"
          ]
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker_experiments_management"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sagemaker:AddAssociation",
            "sagemaker:CreateAction",
            "sagemaker:CreateArtifact",
            "sagemaker:CreateContext",
            "sagemaker:CreateExperiment",
            "sagemaker:CreateTrial",
            "sagemaker:CreateTrialComponent",
            "sagemaker:UpdateAction",
            "sagemaker:UpdateArtifact",
            "sagemaker:UpdateContext",
            "sagemaker:UpdateExperiment",
            "sagemaker:UpdateTrial",
            "sagemaker:UpdateTrialComponent",
            "sagemaker:AssociateTrialComponent",
            "sagemaker:DisassociateTrialComponent",
            "sagemaker:DeleteAssociation",
            "sagemaker:DeleteAction",
            "sagemaker:DeleteArtifact",
            "sagemaker:DeleteContext",
            "sagemaker:DeleteExperiment",
            "sagemaker:DeleteTrial",
            "sagemaker:DeleteTrialComponent",
            "sagemaker:DeleteFeatureGroup",
            "sagemaker:UpdateFeatureGroup",
            "sagemaker:UpdateFeatureMetadata",
            "sagemaker:CreateFeatureGroup",
            "sagemaker:PutRecord",
            "sagemaker-mlflow:*",
            "sagemaker:CreateMlflowTrackingServer",
            "sagemaker:UpdateMlflowTrackingServer",
            "sagemaker:DeleteMlflowTrackingServer",
            "sagemaker:StartMlflowTrackingServer",
            "sagemaker:StopMlflowTrackingServer",
            "sagemaker:CreatePresignedMlflowTrackingServerUrl"
          ]
          Resource = "arn:aws:sagemaker:*:*:*/*"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker_experiments_visualization"
    policy = jsonencode({
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
            "sagemaker:DescribeLineageGroup",
            "sagemaker:DescribeFeatureGroup",
            "sagemaker:DescribeFeatureMetadata",
            "sagemaker:GetRecord",
            "sagemaker:BatchGetRecord"
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
    })
  }

  inline_policy {
    name   = "sagemaker_mlflow"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sagemaker-mlflow:*",
            "sagemaker:CreateMlflowTrackingServer",
            "sagemaker:UpdateMlflowTrackingServer",
            "sagemaker:DeleteMlflowTrackingServer",
            "sagemaker:StartMlflowTrackingServer",
            "sagemaker:StopMlflowTrackingServer",
            "sagemaker:CreatePresignedMlflowTrackingServerUrl"
          ]
          Resource = "arn:aws:sagemaker:*:*:mlflow-tracking-server/*"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker_model_management"
    policy = jsonencode({
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
          Resource = "arn:aws:sagemaker:*:*:*/*"
        },
        {
          Effect = "Allow"
          Action = [
            "sagemaker:ListModels",
            "sagemaker:ListModelPackages",
            "sagemaker:ListModelPackageGroups"
          ]
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker_studio_app_permissions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sagemaker:CreateApp",
            "sagemaker:DeleteApp"
          ]
          Resource = format("arn:aws:sagemaker:%s:%s:app/*", data.aws_region.current.name, data.aws_caller_identity.current.account_id)
          Condition = {
            Null = {
              "sagemaker:OwnerUserProfileArn" = true
            }
          }
        },
        {
          Effect = "Allow"
          Action = "sagemaker:CreatePresignedDomainUrl"
          Resource = format("arn:aws:sagemaker:%s:%s:user-profile/%s/%s", data.aws_region.current.name, data.aws_caller_identity.current.account_id, var.SageMakerDomainId, var.data_science_user_profile_name)
        },
        {
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
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = "sagemaker:AddTags"
          Resource = format("arn:aws:sagemaker:%s:%s:*/*", data.aws_region.current.name, data.aws_caller_identity.current.account_id)
          Condition = {
            Null = {
              "sagemaker:TaggingAction" = false
            }
          }
        },
        {
          Effect = "Allow"
          Action = [
            "sagemaker:CreateSpace",
            "sagemaker:UpdateSpace",
            "sagemaker:DeleteSpace"
          ]
          Resource = format("arn:aws:sagemaker:%s:%s:space/%s/*", data.aws_region.current.name, data.aws_caller_identity.current.account_id, var.SageMakerDomainId)
          Condition = {
            Null = {
              "sagemaker:OwnerUserProfileArn" = true
            }
          }
        },
        {
          Effect = "Allow"
          Action = [
            "sagemaker:CreateSpace",
            "sagemaker:UpdateSpace",
            "sagemaker:DeleteSpace"
          ]
          Resource = format("arn:aws:sagemaker:%s:%s:space/%s/*", data.aws_region.current.name, data.aws_caller_identity.current.account_id, var.SageMakerDomainId)
          Condition = {
            ArnLike = {
              "sagemaker:OwnerUserProfileArn" = format("arn:aws:sagemaker:%s:%s:user-profile/%s/%s", data.aws_region.current.name, data.aws_caller_identity.current.account_id, var.SageMakerDomainId, var.data_science_user_profile_name)
            }
            StringEquals = {
              "sagemaker:SpaceSharingType" = ["Private", "Shared"]
            }
          }
        },
        {
          Effect = "Allow"
          Action = [
            "sagemaker:CreateApp",
            "sagemaker:DeleteApp"
          ]
          Resource = format("arn:aws:sagemaker:%s:%s:app/%s/*", data.aws_region.current.name, data.aws_caller_identity.current.account_id, var.SageMakerDomainId)
          Condition = {
            ArnLike = {
              "sagemaker:OwnerUserProfileArn" = format("arn:aws:sagemaker:%s:%s:user-profile/%s/%s", data.aws_region.current.name, data.aws_caller_identity.current.account_id, var.SageMakerDomainId, var.data_science_user_profile_name)
            }
            StringEquals = {
              "sagemaker:SpaceSharingType" = ["Private"]
            }
          }
        },
        {
          Effect = "Deny"
          Sid    = "DenySageMakerCanvasCreateApp"
          Action = "sagemaker:CreateApp"
          Resource = format("arn:aws:sagemaker:%s:%s:app/%s/%s/canvas/*", data.aws_region.current.name, data.aws_caller_identity.current.account_id, var.SageMakerDomainId, var.data_science_user_profile_name)
        },
        {
          Effect = "Allow"
          Action = [
            "sagemaker:CreateApp",
            "sagemaker:DeleteApp"
          ]
          Resource = format("arn:aws:sagemaker:*:*:app/%s/*/*/*", var.SageMakerDomainId)
          Condition = {
            StringEquals = {
              "sagemaker:SpaceSharingType" = ["Shared"]
            }
          }
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker_ecr_permissions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:DescribeImages",
            "ecr:DescribeRepositories",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetAuthorizationToken"
          ]
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "allow_aws_service_actions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "cloudwatch:DeleteAlarms",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:GetMetricData",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:ListMetrics",
            "cloudwatch:PutMetricAlarm",
            "cloudwatch:PutMetricData",
            "ec2:CreateNetworkInterface",
            "ec2:CreateNetworkInterfacePermission",
            "ec2:CreateVpcEndpoint",
            "ec2:DeleteNetworkInterface",
            "ec2:DeleteNetworkInterfacePermission",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeVpcs",
            "logs:CreateLogDelivery",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DeleteLogDelivery",
            "logs:Describe*",
            "logs:GetLogDelivery",
            "logs:GetLogEvents",
            "logs:ListLogDeliveries",
            "logs:PutLogEvents",
            "logs:PutResourcePolicy",
            "logs:UpdateLogDelivery"
          ]
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "glue_management_actions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "glue:GetTable",
            "glue:UpdateTable",
            "glue:GetDatabase",
            "glue:CreateDatabase",
            "glue:CreateTable"
          ]
          Resource = [
            "arn:aws:glue:*:*:catalog",
            "arn:aws:glue:*:*:database/*",
            "arn:aws:glue:*:*:table/*/*"
          ]
        }
      ]
    })
  }

  inline_policy {
    name   = "kms_management_actions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "kms:CreateGrant",
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:Encrypt",
            "kms:GenerateDataKey*",
            "kms:ReEncrypt*",
            "kms:ListKeys",
            "kms:DescribeKey"
          ]
          Resource = format("arn:aws:kms:%s:%s:key/*", data.aws_region.current.name, data.aws_caller_identity.current.account_id)
        }
      ]
    })
  }
}

resource "aws_sagemaker_user_profile" "data_science_user_profile" {
  domain_id = var.SageMakerDomainId
  user_profile_name = var.data_science_user_profile_name
  user_settings {
    execution_role = aws_iam_role.data_science_sage_maker_execution_role.arn
  }
}

output "data_science_user_profile_arn" {
  description = "The ARN of the new User Profile"
  value = aws_sagemaker_user_profile.data_science_user_profile.arn
}
