provider "aws" {
  region = "us-east-1" 
}

variable "SageMakerDomainId" {
  description = "This variable was an imported value in the Cloudformation Template."
  type        = string
}

variable "ml_ops_engineer_user_profile_name" {
  description = "The name of the new UserProfile"
  type        = string
  default     = "mlops-engineer"
}

variable "sage_maker_studio_security_groups" {
  description = "(Optional) The list of Security Group IDs for the SageMaker Studio Domain. If not provided, the value will be imported from lab_0 stack"
  type        = list(string)
}

variable "sage_maker_studio_subnet_ids" {
  description = "(Optional) The list of Subnet IDs for the SageMaker Studio Domain. If not provided, the value will be imported from lab_0 stack"
  type        = list(string)
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  SageMakerStudioVPCOnlyDomainProvidedCondition = var.SageMakerDomainId != ""
  SageMakerStudioSecurityGroupsCondition         = length(var.sage_maker_studio_security_groups) > 0
  SageMakerStudioSubnetIdsCondition              = length(var.sage_maker_studio_subnet_ids) > 0
  stack_name                                     = "mlops_engineer"
}

resource "aws_iam_role" "ml_ops_engineer_sage_maker_execution_role" {
  name                 = "AmazonSageMakerExecutionRole-${var.ml_ops_engineer_user_profile_name}-${data.aws_region.current.name}"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "sagemaker.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_pipeline_management" {
  name = "SagemakerPipelineManagement"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
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
        ],
        Resource = "arn:aws:sagemaker:*:*:*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sagemaker:ListPipelines",
          "sagemaker:ListPipelineExecutions",
          "sagemaker:ListPipelineExecutionSteps",
          "sagemaker:ListPipelineParametersForExecution"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.stack_name}-${var.SageMakerDomainId}-MLOps-Role"
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "sagemaker.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_model_monitoring" {
  name = "SagemakerModelMonitoring"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:CreateMonitoringSchedule",
          "sagemaker:UpdateMonitoringSchedule",
          "sagemaker:DescribeMonitoringSchedule",
          "sagemaker:DeleteMonitoringSchedule",
          "sagemaker:StartMonitoringSchedule",
          "sagemaker:StopMonitoringSchedule",
          "sagemaker:CreateProcessingJob",
          "sagemaker:DescribeProcessingJob",
          "sagemaker:StopProcessingJob"
        ],
        Resource = "arn:aws:sagemaker:*:*:*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sagemaker:ListMonitoringSchedules",
          "sagemaker:ListProcessingJobs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.stack_name}-${var.SageMakerDomainId}-MLOps-Role"
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "sagemaker.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_model_management" {
  name = "SagemakerModelManagement"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
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
        ],
        Resource = "arn:aws:sagemaker:*:*:*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sagemaker:ListModels",
          "sagemaker:ListModelPackages",
          "sagemaker:ListModelPackageGroups"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.stack_name}-${var.SageMakerDomainId}-MLOps-Role"
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "sagemaker.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_experiment" {
  name = "SagemakerExperiment"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:DescribeAction",
          "sagemaker:DescribeArtifact",
          "sagemaker:DescribeContext",
          "sagemaker:DescribeExperiment",
          "sagemaker:DescribeTrial",
          "sagemaker:DescribeTrialComponent",
          "sagemaker:DescribeLineageGroup"
        ],
        Resource = "arn:aws:sagemaker:*:*:*/*"
      },
      {
        Effect = "Allow",
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
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_processing" {
  name = "SagemakerProcessing"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:CreateTrainingJob",
          "sagemaker:CreateTransformJob",
          "sagemaker:CreateProcessingJob",
          "sagemaker:CreateAutoMLJob",
          "sagemaker:CreateHyperParameterTuningJob",
          "sagemaker:StopTrainingJob",
          "sagemaker:StopProcessingJob",
          "sagemaker:StopAutoMLJob",
          "sagemaker:StopHyperParameterTuningJob",
          "sagemaker:DescribeTrainingJob",
          "sagemaker:DescribeTransformJob",
          "sagemaker:DescribeProcessingJob",
          "sagemaker:DescribeAutoMLJob",
          "sagemaker:DescribeHyperParameterTuningJob",
          "sagemaker:UpdateTrainingJob",
          "sagemaker:BatchGetMetrics"
        ],
        Resource = "arn:aws:sagemaker:*:*:*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sagemaker:Search",
          "sagemaker:ListTrainingJobs",
          "sagemaker:ListTransformJobs",
          "sagemaker:ListProcessingJobs",
          "sagemaker:ListAutoMLJobs",
          "sagemaker:ListCandidatesForAutoMLJob",
          "sagemaker:ListHyperParameterTuningJobs",
          "sagemaker:ListTrainingJobsForHyperParameterTuningJob"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.stack_name}-${var.SageMakerDomainId}-MLOps-Role"
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "sagemaker.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_endpoint" {
  name = "SagemakerEndpoint"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:CreateEndpointConfig",
          "sagemaker:CreateEndpoint",
          "sagemaker:DeleteEndpointConfig",
          "sagemaker:DeleteEndpoint",
          "sagemaker:UpdateEndpoint",
          "sagemaker:UpdateEndpointWeightsAndCapacities",
          "sagemaker:DescribeEndpoint",
          "sagemaker:DescribeEndpointConfig"
        ],
        Resource = "arn:aws:sagemaker:*:*:*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sagemaker:ListEndpoints",
          "sagemaker:ListEndpointConfigs"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "sage_maker_ml_studio_app_permission_policy" {
  name = "SageMaker_MLStudioAppPermission_Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "SMStudioUserProfileAppPermissionsCreateAndDelete",
        Effect = "Allow",
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ],
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/*",
        Condition = {
          Null = {
            "sagemaker:OwnerUserProfileArn" = "false"
          }
        }
      },
      {
        Sid = "SMStudioCreatePresignedDomainUrlForUserProfile",
        Effect = "Allow",
        Action = [
          "sagemaker:CreatePresignedDomainUrl"
        ],
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/${var.SageMakerDomainId}/${var.ml_ops_engineer_user_profile_name}"
      },
      {
        Sid = "SMStudioAppPermissionsListAndDescribe",
        Effect = "Allow",
        Action = [
          "sagemaker:ListApps",
          "sagemaker:ListDomains",
          "sagemaker:ListUserProfiles",
          "sagemaker:ListSpaces",
          "sagemaker:DescribeApp",
          "sagemaker:DescribeDomain",
          "sagemaker:DescribeUserProfile",
          "sagemaker:DescribeSpace"
        ],
        Resource = "*"
      },
      {
        Sid = "SMStudioAppPermissionsTagOnCreate",
        Effect = "Allow",
        Action = [
          "sagemaker:AddTags"
        ],
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*",
        Condition = {
          Null = {
            "sagemaker:TaggingAction" = "false"
          }
        }
      },
      {
        Sid = "SMStudioRestrictSharedSpacesWithoutOwners",
        Effect = "Allow",
        Action = [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ],
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:space/${var.SageMakerDomainId}/*",
        Condition = {
          Null = {
            "sagemaker:OwnerUserProfileArn" = "false"
          }
        }
      },
      {
        Sid = "SMStudioRestrictSpacesToOwnerUserProfile",
        Effect = "Allow",
        Action = [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ],
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:space/${var.SageMakerDomainId}/*",
        Condition = {
          ArnLike = {
            "sagemaker:OwnerUserProfileArn" = [
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/${var.SageMakerDomainId}/*"
            ]
          },
          StringEquals = {
            "sagemaker:SpaceSharingType" = [
              "Private",
              "Shared"
            ]
          }
        }
      },
      {
        Sid = "SMStudioRestrictCreatePrivateSpaceAppsToOwnerUserProfile",
        Effect = "Allow",
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ],
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/${var.SageMakerDomainId}/*",
        Condition = {
          ArnLike = {
            "sagemaker:OwnerUserProfileArn" = [
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/${var.SageMakerDomainId}/${var.ml_ops_engineer_user_profile_name}"
            ]
          },
          StringEquals = {
            "sagemaker:SpaceSharingType" = [
              "Private"
            ]
          }
        }
      },
      {
        Sid = "AllowAppActionsForSharedSpaces",
        Effect = "Allow",
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ],
        Resource = "arn:aws:sagemaker:*:*:app/${var.SageMakerDomainId}/*/*/*",
        Condition = {
          StringEquals = {
            "sagemaker:SpaceSharingType" = [
              "Shared"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_pipeline_management_attachment" {
  role       = aws_iam_role.ml_ops_engineer_sage_maker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_pipeline_management.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_model_monitoring_attachment" {
  role       = aws_iam_role.ml_ops_engineer_sage_maker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_model_monitoring.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_model_management_attachment" {
  role       = aws_iam_role.ml_ops_engineer_sage_maker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_model_management.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_experiment_attachment" {
  role       = aws_iam_role.ml_ops_engineer_sage_maker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_experiment.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_processing_attachment" {
  role       = aws_iam_role.ml_ops_engineer_sage_maker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_processing.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_endpoint_attachment" {
  role       = aws_iam_role.ml_ops_engineer_sage_maker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_endpoint.arn
}

resource "aws_iam_role_policy_attachment" "sage_maker_ml_studio_app_permission_policy_attachment" {
  role       = aws_iam_role.ml_ops_engineer_sage_maker_execution_role.name
  policy_arn = aws_iam_policy.sage_maker_ml_studio_app_permission_policy.arn
}

resource "aws_sagemaker_user_profile" "ml_ops_engineer_user_profile" {
  domain_id         = var.SageMakerDomainId
  user_profile_name = var.ml_ops_engineer_user_profile_name
  user_settings {
    execution_role = aws_iam_role.ml_ops_engineer_sage_maker_execution_role.arn
  }
}

output "ml_ops_engineer_user_profile_arn" {
  description = "The ARN of the new User Profile"
  value       = aws_sagemaker_user_profile.ml_ops_engineer_user_profile.arn
}
