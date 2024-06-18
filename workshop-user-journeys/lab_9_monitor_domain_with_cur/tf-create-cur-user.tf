provider "aws" {
  region = "us-east-1" # specify your region
}

variable "CURRoleName" {
  description = "The name of the new Cost & Usage Reports IAM Role"
  default     = "SageMakerCostUsageReportsRole"
}

variable "UserProfileName" {
  description = "The name of the new Cost & Usage Reports User Profile"
  default     = "studio-cur-user-profile"
}

resource "aws_s3_bucket" "cur_bucket" {
  bucket = "cur-bucket-${data.aws_caller_identity.current.account_id}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    abort_incomplete_multipart_upload_days = 1
  }

  public_access_block {
    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
    restrict_public_buckets = true
  }
}

data "aws_caller_identity" "current" {}

resource "aws_glue_catalog_database" "cur_database" {
  name = "cur_database"
}

resource "aws_iam_role" "cur_glue_crawler_role" {
  name = "CURGlueCrawlerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "GlueCrawlerS3Access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::cur-bucket-${data.aws_caller_identity.current.account_id}/*",
          "arn:aws:s3:::cur-bucket-${data.aws_caller_identity.current.account_id}"
        ]
      }]
    })
  }
}

resource "aws_glue_crawler" "cur_crawler" {
  name          = "cur_crawler"
  role          = aws_iam_role.cur_glue_crawler_role.arn
  database_name = aws_glue_catalog_database.cur_database.name

  s3_target {
    path = "s3://cur-bucket-${data.aws_caller_identity.current.account_id}/sagemaker-cur/"
  }

  schedule = "cron(0 12 * * ? *)"
  table_prefix = "cur_"
}

resource "aws_athena_workgroup" "cur_workgroup" {
  name        = "AthenaWorkGroup"
  description = "WorkGroup for CUR Athena Queries"
  state       = "ENABLED"
  recursive_delete_option = true

  configuration {
    bytes_scanned_cutoff_per_query = 200000000
    enforce_workgroup_configuration = false
    publish_cloudwatch_metrics_enabled = true
    requester_pays_enabled = false
    result_configuration {
      output_location = "s3://cur-bucket-${data.aws_caller_identity.current.account_id}/athena-results/"
    }
  }
}

resource "aws_iam_role" "quicksight_iam_role" {
  name = "QuickSightIAMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "quicksight.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "QuickSightAccess"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Resource = [
            "arn:aws:s3:::cur-bucket-${data.aws_caller_identity.current.account_id}/*",
            "arn:aws:s3:::cur-bucket-${data.aws_caller_identity.current.account_id}"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "athena:StartQueryExecution",
            "athena:GetQueryResults",
            "athena:ListQueryExecutions"
          ]
          Resource = [
            "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/AthenaWorkGroup",
            "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:query/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "glue:GetTable",
            "glue:GetTableVersion",
            "glue:GetTableVersions",
            "glue:GetDatabase"
          ]
          Resource = [
            "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
            "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/cur_database",
            "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/cur_database/*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role" "sagemaker_cost_usage_reports_role" {
  name = var.CURRoleName

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = [
          "sagemaker.amazonaws.com",
          "athena.amazonaws.com",
          "quicksight.amazonaws.com",
          "s3.amazonaws.com"
        ]
      }
      Action = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "AthenaAccessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryResults",
          "athena:ListQueryExecutions"
        ]
        Resource = [
          "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/*",
          "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:query/*"
        ]
      }]
    })
  }

  inline_policy {
    name = "QuickSightAccessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "quicksight:Describe*",
          "quicksight:List*"
        ]
        Resource = [
          "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user/${data.aws_caller_identity.current.account_id}/*",
          "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dataset/*",
          "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:analysis/*",
          "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dashboard/*",
          "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:namespace/default"
        ]
      }]
    })
  }

  inline_policy {
    name = "CURAccessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "cur:DescribeReportDefinitions",
          "cur:GetReportData"
        ]
        Resource = "arn:aws:cur:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report/*"
      }]
    })
  }

  inline_policy {
    name = "S3AccessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::*"
      }]
    })
  }

  inline_policy {
    name = "CostExplorerAccessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetReservationUtilization",
          "ce:GetSavingsPlansUtilization",
          "ce:DescribeCostCategoryDefinition"
        ]
        Resource = "*"
      }]
    })
  }

  inline_policy {
    name = "BudgetsAccessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "budgets:ViewBudget",
          "budgets:ModifyBudget"
        ]
        Resource = "arn:aws:budgets::${data.aws_caller_identity.current.account_id}:budget/*"
      }]
    })
  }

  inline_policy {
    name = "SageMakerCanvasDenyPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Deny"
        Action = [
          "sagemaker:CreateCanvasApp",
          "sagemaker:DeleteCanvasApp",
          "sagemaker:ListCanvasApp",
          "sagemaker:DescribeCanvasApp",
          "sagemaker:InvokeCanvasApp",
          "sagemaker:StartCanvasApp",
          "sagemaker:StopCanvasApp"
        ]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:canvas-app/*"
      }]
    })
  }
}

resource "aws_sagemaker_user_profile" "user_profile" {
  domain_id         = data.aws_sagemaker_domain.domain.id
  user_profile_name = var.UserProfileName

  user_settings {
    execution_role = aws_iam_role.sagemaker_cost_usage_reports_role.arn
  }
}

data "aws_sagemaker_domain" "domain" {
  name = "your-sagemaker-domain-name"  # Replace with your actual SageMaker domain name
}

output "SageMakerCostUsageReportsRoleARN" {
  description = "ARN of the IAM role for SageMaker cost usage reports"
  value       = aws_iam_role.sagemaker_cost_usage_reports_role.arn
}

output "SageMakerUserProfileName" {
  description = "Name of the SageMaker User Profile for cost optimization"
  value       = aws_sagemaker_user_profile.user_profile.user_profile_name
}
