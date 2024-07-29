provider "aws" {
  region = "us-east-1"
}

variable "SageMakerDomainId" {
  description = "This variable was an imported value in the Cloudformation Template."
}

variable "SageMakerCloudformationSubnetId" {
  description = "This variable was an imported value in the Cloudformation Template."
}

variable "SageMakerCloudformationSecurityGroup" {
  description = "This variable was an imported value in the Cloudformation Template."
}

variable "hybrid_team_user_profile_name" {
  description = "The name of the new UserProfile"
  type        = string
  default     = "hybrid-team"
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "hybrid_sage_maker_execution_role" {
  name                   = "AmazonSageMakerExecutionRole-${var.hybrid_team_user_profile_name}-${data.aws_region.current.name}"
  force_detach_policies  = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = [
            "sagemaker.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect    = "Allow"
        Principal = {
          Service = [
            "bedrock.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "iam-pass-role"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["iam:PassRole"]
          Resource = [
            join("", ["arn:aws:iam::", data.aws_caller_identity.current.account_id, ":role/service-role/AmazonSageMakerExecutionRole-", var.hybrid_team_user_profile_name, "-", data.aws_region.current.name]),
            join("", ["arn:aws:iam::", data.aws_caller_identity.current.account_id, ":role/AmazonSageMakerExecutionRole-", var.hybrid_team_user_profile_name, "-", data.aws_region.current.name])
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
    name   = "s3-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
          Resource = "arn:aws:s3:::*"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker-common-job-management"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "sagemaker:CreateTrainingJob",
            "sagemaker:CreateTransformJob",
            "sagemaker:CreateProcessingJob",
            "sagemaker:CreateAutoMLJob",
            "sagemaker:CreateHyperParameterTuningJob",
            "sagemaker:UpdateTrainingJob",
            "sagemaker:CreatePresignedNotebookInstanceUrl",
            "sagemaker:DescribeNotebookInstance",
            "sagemaker:StartNotebookInstance",
            "sagemaker:StopNotebookInstance",
            "sagemaker:CreateNotebookInstanceLifecycleConfig",
            "sagemaker:DeleteNotebookInstanceLifecycleConfig",
            "sagemaker:CreateModelQualityJobDefinition",
            "sagemaker:ListModelQualityJobDefinitions",
            "sagemaker:UpdateModelQualityJobDefinition",
            "sagemaker:DeleteModelQualityJobDefinition",
            "sagemaker:CreateMonitoringSchedule",
            "sagemaker:DescribeMonitoringSchedule",
            "sagemaker:ListMonitoringSchedules",
            "sagemaker:UpdateMonitoringSchedule",
            "sagemaker:DeleteMonitoringSchedule",
            "sagemaker:CreateProject",
            "sagemaker:DescribeProject",
            "sagemaker:ListProjects",
            "sagemaker:UpdateProject",
            "sagemaker:DeleteProject",
            "sagemaker:CreateModel",
            "sagemaker:DescribeModel",
            "sagemaker:ListModels",
            "sagemaker:UpdateModel",
            "sagemaker:DeleteModel",
            "sagemaker:CreateModelPackage",
            "sagemaker:DescribeModelPackage",
            "sagemaker:ListModelPackages",
            "sagemaker:UpdateModelPackage",
            "sagemaker:DeleteModelPackage",
            "sagemaker:CreateModelPackageGroup",
            "sagemaker:DescribeModelPackageGroup",
            "sagemaker:ListModelPackageGroups",
            "sagemaker:UpdateModelPackageGroup",
            "sagemaker:DeleteModelPackageGroup"
          ]
          Resource = "arn:aws:sagemaker:*:*:*/*"
          Condition = {
            "ForAllValues:StringEquals" = {
              "sagemaker:VpcSecurityGroupIds" = [var.SageMakerCloudformationSecurityGroup]
              "sagemaker:VpcSubnets" = [var.SageMakerCloudformationSubnetId]
            }
            Null = {
              "sagemaker:VpcSubnets" = false
              "sagemaker:VpcSecurityGroupIds" = false
            }
          }
        },
        {
          Effect   = "Allow"
          Action   = [
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
          Effect   = "Allow"
          Action   = [
            "sagemaker:Search",
            "sagemaker:ListTrainingJobs",
            "sagemaker:ListTransformJobs",
            "sagemaker:ListProcessingJobs",
            "sagemaker:ListAutoMLJobs",
            "sagemaker:ListCandidatesForAutoMLJob",
            "sagemaker:ListHyperParameterTuningJobs",
            "sagemaker:ListTrainingJobsForHyperParameterTuningJob"
          ]
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker-experiments-management"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
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
            "sagemaker:DeleteTrialComponent"
          ]
          Resource = "arn:aws:sagemaker:*:*:*/*"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker-experiments-visualization"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
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
          Effect   = "Allow"
          Action   = [
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
    name   = "sagemaker-model-management"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
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
          Effect   = "Allow"
          Action   = [
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
    name   = "sagemaker-studio-app-permissions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "sagemaker:CreateApp",
            "sagemaker:DeleteApp"
          ]
          Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/*"
          Condition = {
            Null = {
              "sagemaker:OwnerUserProfileArn" = "true"
            }
          }
        },
        {
          Effect   = "Allow"
          Action   = [
            "sagemaker:CreatePresignedDomainUrl"
          ]
          Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":user-profile/${var.SageMakerDomainId}/${var.hybrid_team_user_profile_name}"])
        },
        {
          Effect   = "Allow"
          Action   = [
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
          Effect   = "Allow"
          Action   = [
            "sagemaker:AddTags"
          ]
          Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
          Condition = {
            Null = {
              "sagemaker:TaggingAction" = "false"
            }
          }
        },
        {
          Effect   = "Allow"
          Action   = [
            "sagemaker:CreateSpace",
            "sagemaker:UpdateSpace",
            "sagemaker:DeleteSpace"
          ]
          Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":space/${var.SageMakerDomainId}/*"])
          Condition = {
            Null = {
              "sagemaker:OwnerUserProfileArn" = "true"
            }
          }
        },
        {
          Effect   = "Allow"
          Action   = [
            "sagemaker:CreateSpace",
            "sagemaker:UpdateSpace",
            "sagemaker:DeleteSpace"
          ]
          Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":space/${var.SageMakerDomainId}/*"])
          Condition = {
            ArnLike = {
              "sagemaker:OwnerUserProfileArn" = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":user-profile/${var.SageMakerDomainId}/${var.hybrid_team_user_profile_name}"])
            }
            StringEquals = {
              "sagemaker:SpaceSharingType" = [
                "Private",
                "Shared"
              ]
            }
          }
        },
        {
          Effect   = "Allow"
          Action   = [
            "sagemaker:CreateApp",
            "sagemaker:DeleteApp"
          ]
          Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":app/${var.SageMakerDomainId}/*"])
          Condition = {
            ArnLike = {
              "sagemaker:OwnerUserProfileArn" = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":user-profile/${var.SageMakerDomainId}/${var.hybrid_team_user_profile_name}"])
            }
            StringEquals = {
              "sagemaker:SpaceSharingType" = [
                "Private"
              ]
            }
          }
        },
        {
          Effect = "Deny"
          Sid    = "DenySageMakerCanvasCreateApp"
          Action = [
            "sagemaker:CreateApp"
          ]
          Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":app/${var.SageMakerDomainId}/${var.hybrid_team_user_profile_name}/canvas/*"])
        },
        {
          Effect   = "Allow"
          Action   = [
            "sagemaker:CreateApp",
            "sagemaker:DeleteApp"
          ]
          Resource = "arn:aws:sagemaker:*:*:app/${var.SageMakerDomainId}/*/*/*"
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

  inline_policy {
    name   = "sagemaker-ecr-permissions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:DescribeImages",
            "ecr:DescribeRepositories",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetAuthorizationToken",
            "ecr:ListImages"
          ]
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "sagemaker:CreateEndpointConfig",
            "sagemaker:DescribeEndpointConfig",
            "sagemaker:ListEndpointConfigs",
            "sagemaker:DeleteEndpointConfig",
            "sagemaker:UpdateEndpointConfig",
            "sagemaker:ListExperiments",
            "sagemaker:DescribeExperiment",
            "sagemaker:ListTrials",
            "sagemaker:DescribeTrial",
            "sagemaker:ListTrialComponents",
            "sagemaker:DescribeTrialComponent",
            "sagemaker:CreatePipeline",
            "sagemaker:DescribePipeline",
            "sagemaker:ListPipelines",
            "sagemaker:UpdatePipeline",
            "sagemaker:DeletePipeline",
            "sagemaker:StartPipelineExecution",
            "sagemaker:DescribePipelineExecution",
            "sagemaker:ListPipelineExecutions",
            "sagemaker:StopPipelineExecution",
            "sagemaker:CreatePipelineDefinitionForPath",
            "sagemaker:DescribePipelineDefinitionForPath",
            "sagemaker:ListPipelineDefinitionForPaths"
          ]
          Resource = "arn:aws:sagemaker:*:*:*/*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams",
            "logs:GetLogEvents"
          ]
          Resource = "arn:aws:sagemaker:*:*:*/*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "events:PutRule",
            "events:DescribeRule",
            "events:PutTargets",
            "events:RemoveTargets",
            "events:DeleteRule"
          ]
          Resource = [
            "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/SageMaker*"
          ]
        },
        {
          Effect   = "Allow"
          Action   = [
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetBucketPolicy",
            "s3:PutBucketPolicy",
            "s3:DeleteBucket",
            "s3:CreateBucket",
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
          ]
          Resource = [
            "arn:aws:s3:::*sagemaker*"
          ]
        }
      ]
    })
  }

  inline_policy {
    name   = "allow-aws-service-actions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
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
}

resource "aws_sagemaker_user_profile" "hybrid_team_user_profile" {
  domain_id          = var.SageMakerDomainId
  user_profile_name  = var.hybrid_team_user_profile_name

  user_settings {
    execution_role = aws_iam_role.hybrid_sage_maker_execution_role.arn
  }
}

output "hybrid_team_user_profile_arn" {
  description = "The ARN of the new User Profile"
  value       = aws_sagemaker_user_profile.hybrid_team_user_profile.arn
}
