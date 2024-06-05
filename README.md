# SageMaker Studio Administrator IaC Templates

![Studio Banner](./media/sagemaker-banner.png)

## Overview

This repository is dedicated for Amazon SageMaker Studio Administration Infrastructure as Code templates to spin-up SageMaker Studio resources.

## Prerequisites

Before getting started, ensure you have the following prerequisites installed:

- [Homebrew](https://brew.sh/): If you're on macOS, you can install `make` using Homebrew by running:
  ```bash
  brew install make
  ```
- [Python](https://www.python.org/): Make sure you have Python installed. You can download it from the official Python website.


## Installation

 1. Clone the repository
    ```bash
    git clone https://github.com/aws-samples/sagemaker-studio-admin-iac-templates.git
2. Navigate to the repo directory
    ```bash
    cd sagemaker-studio-admin-iac-templates
3. Install the required dependencies
    ```bash
    make install
## Table of User Journeys as Infrastructure-as-Code

The table below provides a scenario and a sample cloudformation or terraform templates that can be launched into your account.



| Template Description      | AWS CloudFormation | HashiCorp Terraform |
| :------------------------ | :-----------:  | :--------:|
| Create SageMaker Studio, User Profile (with SageMakerFullAccess) in `PublicInternetOnly` mode, in an existing VPC.     | [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/create-studio-and-user-internet-only.yaml)       | [<img src="./media/tficon.png" width="45" height="45" />](./src-terraform-iac/create-studio-and-user-internet-only.tf)       |
| Create SageMaker Studio, User Profile (with SageMakerFullAccess) in `VPCOnly` mode, in an existing VPC. |  [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/create-studio-and-user-vpc-only.yaml)        | [<img src="./media/tficon.png" width="45" height="45" />](./src-terraform-iac/create-studio-and-user-vpc-only.tf)       |
| Create SageMaker Studio, Data Scientist User ([Data Science Role](https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-personas.html#role-manager-personas-data-scientist)) in `VPCOnly` mode, in an existing VPC.  |  [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/create-studio-and-datascientist-vpc-only.yaml)        | [<img src="./media/tficon.png" width="45" height="45" />](./src-terraform-iac/create-studio-and-datascientist-vpc-only.tf)       |
| Create SageMaker Studio, MLOps Engineer User ([MLOps Role](https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-personas.html#role-manager-personas-mlops)) in `VPCOnly` mode, in an existing VPC.  |  [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/create-studio-and-mlopsengineer-vpc-only.yaml)        | [<img src="./media/tficon.png" width="45" height="45" />](./src-terraform-iac/create-studio-and-mlopsengineer-vpc-only.tf)       |


---
---


## Migration Template

This section is reserved for IaCs for migration of your SageMaker Studio from Classic to V2 (re:Invent 2023 release that introduces JupyterLab and Code Editor IDEs).

### Phase 1 Migration

Migrates SageMaker Studio Domain from Classic to V2. This migration action happens in 2 distinct steps,

1. **Step 1: Create a Test Domain from Source Domain**: Creates a test SageMaker Studio domain identical to a source domain with Studio V2 configuration. This domain can be used to test networking, creating apps and spaces, read/write to s3, test access to tools and more.

2. **Step 2: Migrate Source Domain from Classic to V2**: Run SageMaker Studio migration from Classic to V2 by running a `update_domain` action using `boto3` `sagemaker` client.


| Template Description      | AWS CloudFormation | HashiCorp Terraform |
| :------------------------ | :-----------:  | :--------:|
| Step 1: Create a Test Domain from Source Domain     | [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/studio-classic-to-studio-v2/create-testdomain-from-srcdomain.yaml)       | [<img src="./media/tficon.png" width="45" height="45" />](./src-terraform-iac/studio-classic-to-studio-v2/create-testdomain-from-srcdomain.tf)       |
| Step 2: Migrate Source Domain from Classic to V2    | [<img src="./media/cfnicon.jpg" width="50" height="50" />](./src-cloudformation-iac/studio-classic-to-studio-v2/migrate-srcdomain-from-classic-to-v2.yaml)       | [<img src="./media/tficon.png" width="45" height="45" />](./src-terraform-iac/studio-classic-to-studio-v2/migrate-srcdomain-from-classic-to-v2.tf)       |


> :warning: **If you are running Terraform Migration**: Please note, Migration Terraform templates were generated using [cf2tf](https://github.com/DontShaveTheYak/cf2tf) module. Please drop an [issue](https://github.com/aws-samples/sagemaker-studio-admin-iac-templates/issues) if you encounter issues with TF templates.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

Before pushing your code, run pre-commit to ensure your changes pass all checks:
```make pre-commit```

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
