provider "aws" {
  region = "us-west-2"  # Specify your region
}

variable "user_profile_name" {
  description = "The name of the new Cost & Usage Reports User Profile"
  default     = "studio-cur-user-profile"
}

resource "aws_iam_role" "SageMakerCostUsageReportsRole" {
  name = "SageMakerCostUsageReportsRole"

  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Principal : {
          Service : [
            "sagemaker.amazonaws.com",
            "athena.amazonaws.com",
            "quicksight.amazonaws.com",
            "s3.amazonaws.com"
          ]
        }
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "SageMakerCommonActionsPolicy" {
  name = "SageMakerCommonActionsPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "sagemaker:List*",
          "sagemaker:Describe*",
          "sagemaker:InvokeEndpoint"
        ]
        Resource : [
          "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "AthenaAccessPolicy" {
  name = "AthenaAccessPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "athena:StartQueryExecution",
          "athena:GetQueryResults",
          "athena:ListQueryExecutions"
        ]
        Resource : [
          "arn:aws:athena:${var.region}:${data.aws_caller_identity.current.account_id}:workgroup/*",
          "arn:aws:athena:${var.region}:${data.aws_caller_identity.current.account_id}:query/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "QuickSightAccessPolicy" {
  name = "QuickSightAccessPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "quicksight:Describe*",
          "quicksight:List*"
        ]
        Resource : [
          "arn:aws:quicksight:${var.region}:${data.aws_caller_identity.current.account_id}:user/${data.aws_caller_identity.current.account_id}/*",
          "arn:aws:quicksight:${var.region}:${data.aws_caller_identity.current.account_id}:dataset/*",
          "arn:aws:quicksight:${var.region}:${data.aws_caller_identity.current.account_id}:analysis/*",
          "arn:aws:quicksight:${var.region}:${data.aws_caller_identity.current.account_id}:dashboard/*",
          "arn:aws:quicksight:${var.region}:${data.aws_caller_identity.current.account_id}:namespace/default"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "CURAccessPolicy" {
  name = "CURAccessPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "cur:DescribeReportDefinitions",
          "cur:GetReportData"
        ]
        Resource : [
          "arn:aws:cur:${var.region}:${data.aws_caller_identity.current.account_id}:report/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "S3AccessPolicy" {
  name = "S3AccessPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource : [
          "arn:aws:s3:::your-s3-bucket-name/*",
          "arn:aws:s3:::your-s3-bucket-name"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "CostExplorerAccessPolicy" {
  name = "CostExplorerAccessPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetReservationUtilization",
          "ce:GetSavingsPlansUtilization",
          "ce:DescribeCostCategoryDefinition"
        ]
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "BudgetsAccessPolicy" {
  name = "BudgetsAccessPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "budgets:ViewBudget",
          "budgets:ModifyBudget"
        ]
        Resource : [
          "arn:aws:budgets::${data.aws_caller_identity.current.account_id}:budget/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "SageMakerCanvasDenyPolicy" {
  name = "SageMakerCanvasDenyPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Deny"
        Action : [
          "sagemaker:CreateCanvasApp",
          "sagemaker:DeleteCanvasApp",
          "sagemaker:ListCanvasApp",
          "sagemaker:DescribeCanvasApp",
          "sagemaker:InvokeCanvasApp",
          "sagemaker:StartCanvasApp",
          "sagemaker:StopCanvasApp"
        ]
        Resource : [
          "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:canvas-app/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "SageMakerStudioAppPermissionsPolicy" {
  name = "SageMakerStudioAppPermissionsPolicy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:app/*"
        Condition : {
          "Null" : {
            "sagemaker:OwnerUserProfileArn" : "true"
          }
        }
      },
      {
        Effect : "Allow"
        Action : "sagemaker:CreatePresignedDomainUrl"
        Resource : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:user-profile/${var.sagemaker_domain_id}/${var.user_profile_name}"
      },
      {
        Effect : "Allow"
        Action : [
          "sagemaker:ListApps",
          "sagemaker:ListDomains",
          "sagemaker:ListUserProfiles",
          "sagemaker:ListSpaces",
          "sagemaker:DescribeApp",
          "sagemaker:DescribeDomain",
          "sagemaker:DescribeUserProfile",
          "sagemaker:DescribeSpace"
        ]
        Resource : "*"
      },
      {
        Effect : "Allow"
        Action : "sagemaker:AddTags"
        Resource : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:*/*"
        Condition : {
          "Null" : {
            "sagemaker:TaggingAction" : "false"
          }
        }
      },
      {
        Effect : "Allow"
        Action : [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ]
        Resource : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:space/${var.sagemaker_domain_id}/*"
        Condition : {
          "Null" : {
            "sagemaker:OwnerUserProfileArn" : "true"
          }
        }
      },
      {
        Effect : "Allow"
        Action : [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ]
        Resource : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:space/${var.sagemaker_domain_id}/*"
        Condition : {
          "ArnLike" : {
            "sagemaker:OwnerUserProfileArn" : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:user-profile/${var.sagemaker_domain_id}/${var.user_profile_name}"
          },
          "StringEquals" : {
            "sagemaker:SpaceSharingType" : [
              "Private",
              "Shared"
            ]
          }
        }
      },
      {
        Effect : "Allow"
        Action : [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:app/${var.sagemaker_domain_id}/*"
        Condition : {
          "ArnLike" : {
            "sagemaker:OwnerUserProfileArn" : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:user-profile/${var.sagemaker_domain_id}/${var.user_profile_name}"
          },
          "StringEquals" : {
            "sagemaker:SpaceSharingType" : "Private"
          }
        }
      },
      {
        Effect : "Deny"
        Sid : "DenySageMakerCanvasCreateApp"
        Action : "sagemaker:CreateApp"
        Resource : "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:app/${var.sagemaker_domain_id}/${var.user_profile_name}/canvas/*"
      },
      {
        Effect : "Allow"
        Action : [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource : "arn:aws:sagemaker:*:*:app/${var.sagemaker_domain_id}/*/*/*"
        Condition : {
          "StringEquals" : {
            "sagemaker:SpaceSharingType" : "Shared"
          }
        }
      }
    ]
  })
}

resource "aws_sagemaker_user_profile" "SageMakerUserProfile" {
  domain_id        = var.sagemaker_domain_id
  user_profile_name = var.user_profile_name

  user_settings {
    execution_role = aws_iam_role.SageMakerCostUsageReportsRole.arn
  }
}

output "SageMakerCostUsageReportsRoleARN" {
  description = "ARN of the IAM role for SageMaker cost usage reports"
  value       = aws_iam_role.SageMakerCostUsageReportsRole.arn
}

output "SageMakerUserProfileName" {
  description = "Name of the SageMaker User Profile for cost optimization"
  value       = aws_sagemaker_user_profile.SageMakerUserProfile.id
}
