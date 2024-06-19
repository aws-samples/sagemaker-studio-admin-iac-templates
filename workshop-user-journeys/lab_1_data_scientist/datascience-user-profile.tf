// Cloning Terraform src code to /var/folders/1d/p7dclqcx4934dybvv117p3640000gr/T/terraform_src...
 code has been checked out.

variable "SageMakerDomainId" {
  description = "This variable was an imported value in the Cloudformation Template."
}

variable "SageMakerCloudformationSubnetId" {
  description = "This variable was an imported value in the Cloudformation Template."
}

variable "SageMakerCloudformationSecurityGroup" {
  description = "This variable was an imported value in the Cloudformation Template."
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

variable data_science_user_profile_name {
  description = "The name of the new UserProfile"
  type = string
  default = "data-science"
}

resource "aws_iam_role" "data_science_sage_maker_execution_role" {
  name = "AmazonSageMakerExecutionRole-${var.data_science_user_profile_name}-${data.aws_region.current.name}"
  force_detach_policies = [
    {
      PolicyName = "iam-pass-role"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "iam:PassRole"
            ]
            Resource = [
              join("", ["arn:aws:iam::", data.aws_caller_identity.current.account_id, ":role/service-role/AmazonSageMakerExecutionRole-", var.data_science_user_profile_name, "-", data.aws_region.current.name]),
              join("", ["arn:aws:iam::", data.aws_caller_identity.current.account_id, ":role/AmazonSageMakerExecutionRole-", var.data_science_user_profile_name, "-", data.aws_region.current.name])
            ]
            Condition = {
              StringEquals = {
                iam:PassedToService = "sagemaker.amazonaws.com"
              }
            }
          }
        ]
      }
    },
    {
      PolicyName = "s3-access"
      PolicyDocument = {
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
      }
    },
    {
      PolicyName = "sagemaker-common-job-management"
      PolicyDocument = {
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
              ForAllValues:StringEquals = {
                sagemaker:VpcSecurityGroupIds = [
                  var.SageMakerCloudformationSecurityGroup
                ]
                sagemaker:VpcSubnets = [
                  var.SageMakerCloudformationSubnetId
                ]
              }
              Null = {
                sagemaker:VpcSubnets = false
                sagemaker:VpcSecurityGroupIds = false
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
      }
    },
    {
      PolicyName = "sagemaker-experiments-management"
      PolicyDocument = {
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
      }
    },
    {
      PolicyName = "sagemaker-experiments-visualization"
      PolicyDocument = {
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
      }
    },
    {
      PolicyName = "sagemaker-mlflow"
      PolicyDocument = {
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
      }
    },
    {
      PolicyName = "sagemaker-model-management"
      PolicyDocument = {
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
      }
    },
    {
      PolicyName = "sagemaker-studio-app-permissions"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreateApp",
              "sagemaker:DeleteApp"
            ]
            Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/*"
            Condition = {
              Null = {
                sagemaker:OwnerUserProfileArn = "true"
              }
            }
          },
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreatePresignedDomainUrl"
            ]
            Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":user-profile/${sagemaker:DomainId}/${sagemaker:UserProfileName}"])
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
            Action = [
              "sagemaker:AddTags"
            ]
            Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
            Condition = {
              Null = {
                sagemaker:TaggingAction = "false"
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
            Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":space/${sagemaker:DomainId}/*"])
            Condition = {
              Null = {
                sagemaker:OwnerUserProfileArn = "true"
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
            Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":space/${sagemaker:DomainId}/*"])
            Condition = {
              ArnLike = {
                sagemaker:OwnerUserProfileArn = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":user-profile/${sagemaker:DomainId}/${sagemaker:UserProfileName}"])
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
            Effect = "Allow"
            Action = [
              "sagemaker:CreateApp",
              "sagemaker:DeleteApp"
            ]
            Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":app/${sagemaker:DomainId}/*"])
            Condition = {
              ArnLike = {
                sagemaker:OwnerUserProfileArn = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":user-profile/${sagemaker:DomainId}/${sagemaker:UserProfileName}"])
              }
              StringEquals = {
                sagemaker:SpaceSharingType = [
                  "Private"
                ]
              }
            }
          },
          {
            Effect = "Deny"
            Sid = "DenySageMakerCanvasCreateApp"
            Action = [
              "sagemaker:CreateApp"
            ]
            Resource = join("", ["arn:aws:sagemaker:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":app/${sagemaker:DomainId}/${sagemaker:UserProfileName}/canvas/*"])
          },
          {
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
    },
    {
      PolicyName = "sagemaker-ecr-permissions"
      PolicyDocument = {
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
      }
    },
    {
      PolicyName = "allow-aws-service-actions"
      PolicyDocument = {
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
      }
    },
    {
      PolicyName = "glue-management-actions"
      PolicyDocument = {
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
      }
    },
    {
      PolicyName = "kms-management-actions"
      PolicyDocument = {
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
            Resource = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
          }
        ]
      }
    }
  ]
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
        Action = [
          "sts:AssumeRole"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "bedrock.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSageMakerFeatureStoreAccess"
  ]
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