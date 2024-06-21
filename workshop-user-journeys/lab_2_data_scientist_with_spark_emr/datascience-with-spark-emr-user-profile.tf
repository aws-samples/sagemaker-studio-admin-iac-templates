// Existing Terraform src code found at /var/folders/xt/bwrhjh2s1ld30n8xcgngtmhm0000gr/T/terraform_src.

data "aws_partition" "current" {}

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

locals {
  mappings = {
    ClusterConfigurations = {
      emr = {
        BootStrapScriptFile = "https://raw.githubusercontent.com/pranavvm26/sagemaker-studio-emr/main/cloudformation/getting_started/emr_bootstrapping/installpylibs-py39.sh"
        StepScriptFile = "https://raw.githubusercontent.com/pranavvm26/sagemaker-studio-emr/main/cloudformation/getting_started/emr_bootstrapping/configurekdc.sh"
      }
    }
  }
  stack_id = uuidv5("dns", "datascience-with-spark-emr-user-profile")
  stack_name = "datascience-with-spark-emr-user-profile"
}

variable data_science_user_profile_name {
  description = "SageMaker Studio User Profile Name"
  type = string
  default = "data-scientist-with-emr"
}

variable emr_template_url {
  description = "SageMaker EMR Service Catalog URL"
  type = string
  default = "https://raw.githubusercontent.com/aws-samples/sagemaker-studio-admin-iac-templates/workshop-v1/workshop-user-journeys/lab_2_data_scientist_with_spark_emr/service-catalog-portfolio/EMRonEC2ServiceCatalogTemplate.yaml"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = join("-", ["sagemaker-emr-template-cfn", element(split(""/"", local.stack_id), 2)])
}

resource "aws_iam_role" "data_sciencewith_emr_sage_maker_execution_role" {
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
      PolicyName = "emr-cluster-management-access"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "elasticmapreduce:DescribeCluster",
              "elasticmapreduce:ListInstanceGroups",
              "elasticmapreduce:CreatePersistentAppUI",
              "elasticmapreduce:DescribePersistentAppUI",
              "elasticmapreduce:GetPersistentAppUIPresignedURL",
              "elasticmapreduce:GetOnClusterAppUIPresignedURL",
              "elasticmapreduce:DescribeCluster",
              "elasticmapreduce:ListInstances",
              "elasticmapreduce:ListInstanceGroups",
              "elasticmapreduce:DescribeSecurityConfiguration"
            ]
            Resource = [
              "arn:aws:elasticmapreduce:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "elasticmapreduce:ListClusters",
              "servicecatalog:SearchProducts",
              "servicecatalog:List*",
              "servicecatalog:Describe*",
              "servicecatalog:ProvisionProduct",
              "servicecatalog:GetProvisionedProductOutputs",
              "sagemaker:ListTags",
              "sagemaker:AddTags"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreateProject",
              "sagemaker:DeleteProject"
            ]
            Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/*"
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
              "sagemaker:ListTrainingJobsForHyperParameterTuningJob"
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
              "sagemaker:DeleteTrialComponent"
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
}

resource "aws_sagemaker_user_profile" "data_science_user_profile" {
  domain_id = var.SageMakerDomainId
  user_profile_name = var.data_science_user_profile_name
  user_settings {
    execution_role = aws_iam_role.data_sciencewith_emr_sage_maker_execution_role.arn
  }
}

resource "aws_cloudsearch_domain_service_access_policy" "sage_maker_studio_emr_no_auth_product" {
  // CF Property(Owner) = "AWS"
  domain_name = "SageMaker Studio Domain No Auth EMR"
  // CF Property(ProvisioningArtifactParameters) = [
  //   {
  //     Name = "SageMaker Studio Domain No Auth EMR"
  //     Description = "Provisions a SageMaker domain and No Auth EMR Cluster"
  //     Info = {
  //       LoadTemplateFromURL = var.emr_template_url
  //     }
  //   }
  // ]
  // CF Property(tags) = {
  //   sagemaker:studio-visibility:emr = "true"
  // }
}

resource "aws_servicecatalog_portfolio" "sage_maker_studio_emr_no_auth_product_portfolio" {
  provider_name = "AWS"
  name = "SageMaker Product Portfolio"
}

resource "aws_servicecatalog_product_portfolio_association" "sage_maker_studio_emr_no_auth_product_portfolio_association" {
  portfolio_id = aws_servicecatalog_portfolio.sage_maker_studio_emr_no_auth_product_portfolio.id
  product_id = aws_cloudsearch_domain_service_access_policy.sage_maker_studio_emr_no_auth_product.access_policy
}

resource "aws_iam_role" "emr_no_auth_launch_constraint" {
  force_detach_policies = [
    {
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "s3:*"
            ]
            Effect = "Allow"
            Resource = [
              "arn:${data.aws_partition.current.partition}:s3:::sagemaker-emr-template-cfn-*/*",
              "arn:${data.aws_partition.current.partition}:s3:::sagemaker-emr-template-cfn-*"
            ]
          },
          {
            Action = [
              "s3:GetObject"
            ]
            Effect = "Allow"
            Resource = "*"
            Condition = {
              StringEquals = {
                s3:ExistingObjectTag/servicecatalog:provisioning = "true"
              }
            }
          }
        ]
      }
      PolicyName = "${local.stack_name}-${data.aws_region.current.name}-S3-Policy"
    },
    {
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "sns:Publish"
            ]
            Effect = "Allow"
            Resource = "arn:${data.aws_partition.current.partition}:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        ]
        Version = "2012-10-17"
      }
      PolicyName = "SNSPublishPermissions"
    },
    {
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "ec2:CreateSecurityGroup",
              "ec2:RevokeSecurityGroupEgress",
              "ec2:DeleteSecurityGroup",
              "ec2:createTags",
              "iam:TagRole",
              "ec2:AuthorizeSecurityGroupEgress",
              "ec2:AuthorizeSecurityGroupIngress",
              "ec2:RevokeSecurityGroupIngress"
            ]
            Effect = "Allow"
            Resource = "*"
          }
        ]
        Version = "2012-10-17"
      }
      PolicyName = "EC2Permissions"
    },
    {
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "elasticmapreduce:RunJobFlow"
            ]
            Effect = "Allow"
            Resource = "arn:${data.aws_partition.current.partition}:elasticmapreduce:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/*"
          }
        ]
        Version = "2012-10-17"
      }
      PolicyName = "EMRRunJobFlowPermissions"
    },
    {
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "iam:PassRole"
            ]
            Effect = "Allow"
            Resource = [
              aws_iam_role.emr_clusterinstance_profile_role.arn,
              aws_iam_role.emr_cluster_service_role.arn
            ]
          },
          {
            Action = [
              "iam:CreateInstanceProfile",
              "iam:RemoveRoleFromInstanceProfile",
              "iam:DeleteInstanceProfile",
              "iam:AddRoleToInstanceProfile"
            ]
            Effect = "Allow"
            Resource = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/SC-*"
          }
        ]
        Version = "2012-10-17"
      }
      PolicyName = "IAMPermissions"
    }
  ]
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "servicecatalog.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  }
  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSServiceCatalogAdminFullAccess",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEMRFullAccessPolicy_v2"
  ]
}

resource "aws_servicecatalog_principal_portfolio_association" "sage_maker_studio_emr_no_auth_product_portfolio_principal_association" {
  principal_arn = aws_iam_role.data_sciencewith_emr_sage_maker_execution_role.arn
  portfolio_id = aws_servicecatalog_portfolio.sage_maker_studio_emr_no_auth_product_portfolio.id
  principal_type = "IAM"
}

resource "aws_lightsail_container_service" "sage_maker_studio_portfolio_launch_role_constraint" {
  // CF Property(PortfolioId) = aws_servicecatalog_portfolio.sage_maker_studio_emr_no_auth_product_portfolio.id
  // CF Property(ProductId) = aws_cloudsearch_domain_service_access_policy.sage_maker_studio_emr_no_auth_product.access_policy
  // CF Property(RoleArn) = aws_iam_role.emr_no_auth_launch_constraint.arn
  // CF Property(Description) = "Role used for provisioning"
}

resource "aws_iam_role" "emr_cluster_service_role" {
  assume_role_policy = {
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = [
            "elasticmapreduce.amazonaws.com"
          ]
        }
      }
    ]
    Version = "2012-10-17"
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2"
  ]
  path = "/"
  force_detach_policies = [
    {
      PolicyName = "EMRInstProfilePolicy-${local.stack_name}"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = "iam:PassRole"
            Resource = aws_iam_role.emr_clusterinstance_profile_role.arn
          }
        ]
      }
    }
  ]
}

resource "aws_iam_role" "emr_clusterinstance_profile_role" {
  name = "EMRClustInstProfileRole-${local.stack_name}"
  assume_role_policy = {
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
    Version = "2012-10-17"
  }
  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
  force_detach_policies = [
    {
      PolicyName = "DataScienceRoleInherited"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = "iam:PassRole"
            Resource = aws_iam_role.data_sciencewith_emr_sage_maker_execution_role.arn
          }
        ]
      }
    }
  ]
  path = "/"
}

resource "aws_ebs_snapshot_copy" "copy_zips" {
  // CF Property(ServiceToken) = // Unable to resolve Fn::GetAtt with value: "CopyZipsFunction.Arn"
  // CF Property(DestBucket) = aws_s3_bucket.s3_bucket.id
  // CF Property(GitHubURLs) = [
  //   local.mappings["ClusterConfigurations"]["emr"]["BootStrapScriptFile"],
  //   local.mappings["ClusterConfigurations"]["emr"]["StepScriptFile"]
  // ]
}

resource "aws_iam_role" "bucket_management_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  path = "/"
  force_detach_policies = [
    {
      PolicyName = "BucketManagementLambdaPolicy-${local.stack_name}"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "s3:PutObject",
              "s3:DeleteObject"
            ]
            Resource = [
              "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*"
            ]
          }
        ]
      }
    }
  ]
}

resource "aws_lambda_function" "copy_zips_function" {
  description = "Downloads files from GitHub and uploads them to an S3 bucket"
  handler = "index.handler"
  runtime = "python3.10"
  // Unable to resolve Fn::GetAtt with value: "BucketManagementRole.Arn"
  timeout = 900
  code_signing_config_arn = {
    ZipFile = "import json
import logging
import threading
import boto3
import urllib.request
import cfnresponse

def download_from_github_and_upload_to_s3(github_url, dest_bucket, dest_key):
    with urllib.request.urlopen(github_url) as response:
        file_content = response.read()

    s3 = boto3.client('s3')
    s3.put_object(Bucket=dest_bucket, Key=dest_key, Body=file_content)

def timeout(event, context):
    logging.error('Execution is about to time out, sending failure response to CloudFormation')
    cfnresponse.send(event, context, cfnresponse.FAILED, {}, None)

def handler(event, context):
    # make sure we send a failure to CloudFormation if the function
    # is going to timeout
    timer = threading.Timer((context.get_remaining_time_in_millis()
              / 1000.00) - 0.5, timeout, args=[event, context])
    timer.start()
    print('Received event: %s' % json.dumps(event))
    status = cfnresponse.SUCCESS
    try:
        github_urls = event['ResourceProperties']['GitHubURLs']
        dest_bucket = event['ResourceProperties']['DestBucket']

        if event['RequestType'] == 'Delete':
            
            s3 = boto3.client('s3')
            for github_url in github_urls:
                s3_key = f'artifacts/emr/{github_url.split("/")[-1]}'
                s3.delete_object(Bucket=dest_bucket, Key=s3_key)

        else:
            for github_url in github_urls:
                dest_key = f'artifacts/emr/{github_url.split("/")[-1]}'
                download_from_github_and_upload_to_s3(github_url, dest_bucket, dest_key)
            # copy_objects(source_bucket, dest_bucket, prefix, objects)
    except Exception as e:
        logging.error('Exception: %s' % e, exc_info=True)
        status = cfnresponse.FAILED
    finally:
        timer.cancel()
        cfnresponse.send(event, context, status, {}, None)
"
  }
}

resource "aws_neptune_cluster" "clean_up_bucketon_delete" {
  // CF Property(ServiceToken) = aws_lambda_function.clean_up_bucketon_delete_lambda.arn
  neptune_subnet_group_name = aws_s3_bucket.s3_bucket.id
}

resource "aws_lambda_function" "clean_up_bucketon_delete_lambda" {
  code_signing_config_arn = {
    ZipFile = "import json, boto3, logging
import cfnresponse
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("event: {}".format(event))
    try:
        bucket = event['ResourceProperties']['BucketName']
        logger.info("bucket: {}, event['RequestType']: {}".format(bucket,event['RequestType']))
        if event['RequestType'] == 'Delete':
            s3 = boto3.resource('s3')
            bucket = s3.Bucket(bucket)
            for obj in bucket.objects.filter():
                logger.info("delete obj: {}".format(obj))
                s3.Object(bucket.name, obj.key).delete()

        sendResponseCfn(event, context, cfnresponse.SUCCESS)
    except Exception as e:
        logger.info("Exception: {}".format(e))
        sendResponseCfn(event, context, cfnresponse.FAILED)

def sendResponseCfn(event, context, responseStatus):
    responseData = {}
    responseData['Data'] = {}
    cfnresponse.send(event, context, responseStatus, responseData, "CustomResourcePhysicalID")
"
  }
  handler = "index.lambda_handler"
  runtime = "python3.10"
  memory_size = 128
  timeout = 60
  role = aws_iam_role.bucket_management_role.arn
}

output "sage_maker_emr_demo_cloudformation_emr_clusterinstance_profile_role" {
  description = "Role for EMR Cluster's InstanceProfile"
  value = aws_iam_role.emr_clusterinstance_profile_role.arn
}

output "sage_maker_emr_demo_cloudformation_emr_cluster_service_role" {
  description = "Role for EMR Cluster's Service Role"
  value = aws_iam_role.emr_cluster_service_role.arn
}

output "sage_maker_emr_demo_cloudformation_s3_bucket_name" {
  description = "Bucket Name for Amazon S3 bucket"
  value = aws_s3_bucket.s3_bucket.id
}
