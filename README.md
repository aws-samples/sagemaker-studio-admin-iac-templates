# SageMaker Studio Administrator IaC Templates

![Studio Banner](./media/sagemaker-banner.png)

## Overview

This repository is dedicated for Amazon SageMaker Studio Administration Infrastructure as Code templates to spin-up SageMaker Studio resources.



## Table of IaC

The table below provides a scenario and a sample cloudformation or terraform templates that can be launched into your account.



| Template Description      | AWS CloudFormation | HashiCorp Terraform |
| :------------------------ | :-----------:  | :--------:|
| Create SageMaker Studio with Internet Only      | [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/example.yaml)       | [<img src="./media/tficon.png" width="45" height="45" />](./src-cloudformation-iac/example.yaml)       |
| Create SageMaker Studio with VPC Only   |  [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/example.yaml)        | [<img src="./media/tficon.png" width="45" height="45" />](./src-cloudformation-iac/example.yaml)       |


## Migration Template

### Phase 1 Migration

Migrates SageMaker Studio Domain from Classic to V2. This migration action happens in 2 distinct steps,

1. **Step 1: Create a Test Domain from Source Domain**: Creates a test SageMaker Studio domain identical to a source domain with Studio V2 configuration. This domain can be used to test networking, creating apps and spaces, read/write to s3, test access to tools and more.
   
2. **Step 2: Migrate Source Domain from Classic to V2**: Run SageMaker Studio migration from Classic to V2 by running a `update_domain` action using `boto3` `sagemaker` client.


| Template Description      | AWS CloudFormation | HashiCorp Terraform |
| :------------------------ | :-----------:  | :--------:|
| Step 1: Create a Test Domain from Source Domain     | [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/studio-classic-to-studio-v2/CreateTestDomainFromSourceDomain.yaml)       | WIP       |
| Step 2: Migrate Source Domain from Classic to V2    | [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/studio-classic-to-studio-v2/MigrateSourceDomain.yaml)       | WIP       |



## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.


## License

This library is licensed under the MIT-0 License. See the LICENSE file.

