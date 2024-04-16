## AWS CloudFormation for SageMaker Studio Domain Management

This folder contains two AWS CloudFormation templates for managing AWS SageMaker Studio domains. Each template serves a specific purpose related to the configuration and migration of SageMaker Studio domains.

# 1. Template for Creating a SageMaker Studio Domain

This template replicates settings from an existing SageMaker domain to create a new domain with similar configurations.

### Parameters

    SourceDomainId: The ID of the existing SageMaker Studio Domain to replicate.
    SourceDomainRegion: The AWS Region where the source domain is located.
    TargetDomainName: Desired name for the new target domain.
    TargetDomainUser: Name of the user in the new target domain, with a default set to "test-user".

### Resources

**Lambda Function**

    SageMakerQueryLambda: Queries the existing SageMaker domain to extract configuration details.

**IAM Role**

    SageMakerQueryLambdaRole: Grants the Lambda function permissions to access SageMaker services and CloudWatch Logs.

**SageMaker Domain and User Profile**

    CreateTargetStudioDomain: Uses the configurations retrieved by the Lambda function to create a new SageMaker domain.
    StudioUserProfile: Establishes a user profile within the new domain based on predefined settings.

### Outputs

    TargetDomainId: The ID of the newly created target domain.
    TargetDomainUrl: The URL of the new SageMaker Studio domain.

## 2. Template for Migrating a SageMaker Studio Domain from Classic to V2

This template updates an existing SageMaker Studio Domain from the Classic interface to the V2 interface, ensuring settings are updated to meet current best practices.

### Parameters

    SourceDomainId: The ID of the existing SageMaker Studio Domain to migrate.
    SourceDomainRegion: The AWS Region where the domain is located.

### Resources
**Lambda Function**

    SageMakerMigrateLambda: Handles the update of the SageMaker domain from Classic to V2 settings.

**IAM Role**

    SageMakerMigrateLambdaRole: Allows the Lambda function to perform updates on the domain and log its operations.

**Outputs**

    SourceDomainId: Shows the ID of the domain after migration, confirming the update.
    SourceDomainWebPortalSetting: Displays the 'StudioWebPortal' setting of the domain post-migration.
    SourceDomainDefaultLandingUri: Shows the 'DefaultLandingUri' setting of the domain after the migration.

**Usage Instructions**

    Set Parameters: Input the required parameters such as SourceDomainId and SourceDomainRegion for the chosen template.
    Deploy the Stack: Use the AWS Management Console, AWS CLI, or SDKs to deploy the chosen stack.
    Check Outputs: Verify the outputs for successful deployment and configuration.

**Security and Best Practices**

    Use IAM roles with least privilege principles.
    Test templates in a non-production environment before deployment.
    Regularly review AWS IAM policies and permissions for updates and best practices.
