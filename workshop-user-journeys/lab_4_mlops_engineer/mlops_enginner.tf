// Existing Terraform src code found at /tmp/terraform_src.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

variable sage_maker_studio_vpc_only_domain {
  description = "The ID of the existing SageMaker Studio Domain to import"
  type = string
}

resource "aws_sagemaker_domain" "imported_domain" {
  vpc_id = var.sage_maker_studio_vpc_only_domain
  auth_mode = "IAM"
  default_user_settings {
    execution_role = aws_iam_role.domain_execution_role.arn
  }
}

resource "aws_iam_role" "domain_execution_role" {
  assume_role_policy = {
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
  }
  force_detach_policies = [
    {
      PolicyName = "CustomSageMakerPolicy"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreatePresignedDomainUrl",
              "sagemaker:DescribeDomain",
              "sagemaker:DescribeUserProfile",
              "sagemaker:UpdateDomain",
              "sagemaker:UpdateUserProfile"
            ]
            Resource = [
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
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
            Resource = [
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:notebook-instance/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:model-quality-job-definition/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:monitoring-schedule/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:model/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:model-package/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:model-package-group/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreateApp",
              "sagemaker:DeleteApp",
              "sagemaker:DescribeApp",
              "sagemaker:ListApps"
            ]
            Resource = [
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "ecr:BatchGetImage",
              "ecr:GetAuthorizationToken",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchCheckLayerAvailability",
              "ecr:ListImages",
              "ecr:DescribeRepositories"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreateEndpointConfig",
              "sagemaker:DescribeEndpointConfig",
              "sagemaker:ListEndpointConfigs",
              "sagemaker:DeleteEndpointConfig",
              "sagemaker:UpdateEndpointConfig"
            ]
            Resource = [
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:endpoint-config/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreateEndpoint",
              "sagemaker:DescribeEndpoint",
              "sagemaker:ListEndpoints",
              "sagemaker:DeleteEndpoint",
              "sagemaker:UpdateEndpoint"
            ]
            Resource = [
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:endpoint-config/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "sagemaker:ListExperiments",
              "sagemaker:DescribeExperiment",
              "sagemaker:ListTrials",
              "sagemaker:DescribeTrial",
              "sagemaker:ListTrialComponents",
              "sagemaker:DescribeTrialComponent"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
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
            Resource = [
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pipeline/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pipeline-execution/*",
              "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pipeline-definition/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams",
              "logs:GetLogEvents"
            ]
            Resource = [
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
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
            Effect = "Allow"
            Action = [
              "s3:ListBucket",
              "s3:GetBucketLocation",
              "s3:GetBucketPolicy",
              "s3:PutBucketPolicy",
              "s3:DeleteBucket"
            ]
            Resource = [
              "arn:aws:s3:::*SageMaker*",
              "arn:aws:s3:::*Sagemaker*",
              "arn:aws:s3:::*sagemaker*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "s3:CreateBucket",
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject"
            ]
            Resource = [
              "arn:aws:s3:::*SageMaker*/*",
              "arn:aws:s3:::*Sagemaker*/*",
              "arn:aws:s3:::*sagemaker*/*"
            ]
          }
        ]
      }
    }
  ]
}

output "imported_domain_id" {
  description = "The ID of the imported SageMaker Studio Domain"
  value = aws_sagemaker_domain.imported_domain.arn
}
