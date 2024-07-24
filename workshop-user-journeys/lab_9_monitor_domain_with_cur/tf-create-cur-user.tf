variable "cur_role_name" {
  description = "The name of the new Cost & Usage Reports IAM Role"
  type        = string
  default     = "SageMakerCostUsageReportsRole"
}

variable "user_profile_name" {
  description = "The name of the new Cost & Usage Reports User Profile"
  type        = string
  default     = "studio-cur-user-profile"
}

variable "sagemaker_studio_security_groups" {
  description = "The list of Security Group IDs for the SageMaker Studio Domain"
  type        = list(string)
  default     = []
}

variable "sagemaker_studio_subnet_ids" {
  description = "The list of Subnet IDs for the SageMaker Studio Domain"
  type        = list(string)
  default     = []
}

resource "aws_iam_role" "sagemaker_cost_usage_reports_role" {
  name               = var.cur_role_name
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : [
            "sagemaker.amazonaws.com",
            "athena.amazonaws.com",
            "quicksight.amazonaws.com",
            "s3.amazonaws.com"
          ]
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "AthenaAccessPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "athena:StartQueryExecution",
            "athena:GetQueryResults",
            "athena:ListQueryExecutions",
            "athena:ListWorkGroups"
          ],
          Resource : [
            "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/*",
            "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:query/*"
          ]
        }
      ]
    })
  }

  inline_policy {
    name   = "QuickSightAccessPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "quicksight:Describe*",
            "quicksight:List*",
            "quicksight:ListUsers"
          ],
          Resource : [
            "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user/${data.aws_caller_identity.current.account_id}/*",
            "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dataset/*",
            "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:analysis/*",
            "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dashboard/*",
            "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:namespace/default"
          ]
        }
      ]
    })
  }

  inline_policy {
    name   = "CURAccessPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "cur:DescribeReportDefinitions",
            "cur:GetReportData",
            "cur:PutReportDefinition",
            "cur:DeleteReportDefinition"
          ],
          Resource : [
            "arn:aws:cur:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report/*",
            "arn:aws:cur:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:definition/*"
          ]
        }
      ]
    })
  }

  inline_policy {
    name   = "S3AccessPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "s3:CreateBucket",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBuckets",
            "s3:GetBucketLocation",
            "s3:PutObject",
            "s3:DeleteObject"
          ],
          Resource : "arn:aws:s3:::*"
        }
      ]
    })
  }

  inline_policy {
    name   = "CostExplorerAccessPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "ce:GetCostAndUsage",
            "ce:GetCostForecast",
            "ce:GetReservationUtilization",
            "ce:GetSavingsPlansUtilization",
            "ce:DescribeCostCategoryDefinition"
          ],
          Resource : "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "BudgetsAccessPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "budgets:ViewBudget",
            "budgets:ModifyBudget"
          ],
          Resource : "arn:aws:budgets::${data.aws_caller_identity.current.account_id}:budget/*"
        }
      ]
    })
  }

  inline_policy {
    name   = "SageMakerCanvasDenyPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Deny",
          Action : [
            "sagemaker:CreateCanvasApp",
            "sagemaker:DeleteCanvasApp",
            "sagemaker:ListCanvasApp",
            "sagemaker:DescribeCanvasApp",
            "sagemaker:InvokeCanvasApp",
            "sagemaker:StartCanvasApp",
            "sagemaker:StopCanvasApp"
          ],
          Resource : "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:canvas-app/*"
        }
      ]
    })
  }

  inline_policy {
    name   = "iam-pass-role"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : "iam:PassRole",
          Resource : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AmazonSageMakerExecutionRole-${var.user_profile_name}-${data.aws_region.current.name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonSageMakerExecutionRole-${var.user_profile_name}-${data.aws_region.current.name}"
          ],
          Condition : {
            StringEquals : {
              "iam:PassedToService" : "sagemaker.amazonaws.com"
            }
          }
        }
      ]
    })
  }

  inline_policy {
    name   = "IAMRoleAccessPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : "iam:GetRole",
          Resource : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cur_role_name}"
        }
      ]
    })
  }

  inline_policy {
    name   = "sagemaker-studio-app-permissions"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "sagemaker:CreateApp",
            "sagemaker:DeleteApp",
            "sagemaker:ListTrainingJobs",
            "sagemaker:ListEndpoints",
            "sagemaker:DescribeApp",
            "sagemaker:ListApps",
            "sagemaker:ListDomains",
            "sagemaker:ListUserProfiles",
            "sagemaker:ListSpaces",
            "sagemaker:DescribeApp",
            "sagemaker:DescribeDomain",
            "sagemaker:DescribeUserProfile",
            "sagemaker:DescribeSpace"
          ],
          Resource : "*"
        },
        {
          Effect : "Allow",
          Action : "sagemaker:CreatePresignedDomainUrl",
          Resource : "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/${sagemaker:DomainId}/${sagemaker:UserProfileName}"
        },
        {
          Effect : "Allow",
          Action : "sagemaker:AddTags",
          Resource : "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identit
