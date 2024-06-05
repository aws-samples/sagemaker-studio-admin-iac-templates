// Cloning Terraform src code to /var/folders/xt/bwrhjh2s1ld30n8xcgngtmhm0000gr/T/terraform_src...
 code has been checked out.

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  stack_name = "create-studio-and-datascientist-vpc-only"
}

variable domain_name {
  description = "SageMaker Studio Domain Name"
  type = string
  default = "MyExampleDomain"
}

variable studio_user_name {
  description = "SageMaker Studio User Name"
  type = string
  default = "data-scientist"
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

resource "aws_iam_role" "sage_maker_studio_data_science_role" {
  name = "${local.stack_name}-${var.domain_name}-DataScience-Role"
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

resource "aws_iam_policy" "sage_maker_s3_access_policy" {
  name = "SageMaker_S3Access_Policy"
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
  //   aws_iam_role.sage_maker_studio_data_science_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_common_job_management_policy" {
  name = "SageMaker_CommonJobManagement_Policy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:CreateTrainingJob",
          "sagemaker:CreateTransformJob",
          "sagemaker:CreateProcessingJob",
          "sagemaker:CreateAutoMLJob",
          "sagemaker:CreateHyperParameterTuningJob"
        ]
        Resource = [
          "arn:aws:sagemaker:*:*:*/**"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sagemaker:StopTrainingJob",
          "sagemaker:StopTransformJob",
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
        ]
        Resource = [
          "arn:aws:sagemaker:*:*:*/**"
        ]
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
          "sagemaker:ListTrainingJobsForHyperParameterTuningJob"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.stack_name}-${var.domain_name}-DataScience-Role"
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
  //   aws_iam_role.sage_maker_studio_data_science_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_experiment_managementand_viz_policy" {
  name = "SageMaker_ExperimentManagementandViz_Policy"
  policy = {
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
  //   aws_iam_role.sage_maker_studio_data_science_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_model_management_policy" {
  name = "SageMaker_ModelManagement_Policy"
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:CreateModel"
        ]
        Resource = [
          "arn:aws:sagemaker:*:*:*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
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
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.stack_name}-${var.domain_name}-DataScience-Role"
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
  //   aws_iam_role.sage_maker_studio_data_science_role.arn
  // ]
}

resource "aws_iam_policy" "sage_maker_studio_app_permission_policy" {
  name = "SageMaker_StudioAppPermission_Policy"
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
  //   aws_iam_role.sage_maker_studio_data_science_role.arn
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
    execution_role = aws_iam_role.sage_maker_studio_data_science_role.arn
  }
}

resource "aws_sagemaker_user_profile" "user_profile" {
  domain_id = aws_sagemaker_domain.sage_maker_studio_vpc_only_domain.arn
  user_profile_name = var.studio_user_name
  user_settings {
    execution_role = aws_iam_role.sage_maker_studio_data_science_role.arn
  }
}

output "new_sage_maker_domain" {
  description = "New Domain Id"
  value = aws_sagemaker_domain.sage_maker_studio_vpc_only_domain.arn
}

output "new_sage_maker_execution_role" {
  description = "SageMaker Data Science Role"
  value = aws_iam_role.sage_maker_studio_data_science_role.arn
}

output "sage_maker_domain_url" {
  description = "URL to access the SageMaker Domain"
  value = join("", ["https://console.aws.amazon.com/sagemaker/home?region=", data.aws_region.current.name, "#/studio/", aws_sagemaker_domain.sage_maker_studio_vpc_only_domain.arn])
}
