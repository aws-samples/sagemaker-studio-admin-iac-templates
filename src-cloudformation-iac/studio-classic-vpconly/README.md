# Deploy SageMaker Studio within a secure VPC 🚀

The project facilitate the deployment of an Amazon SageMaker Studio environment within a secure Virtual Private Cloud (VPC) setup. The first template provisions networking resources such as VPC, private subnets, security groups, and VPC endpoints, enabling a secure environment for SageMaker Studio within the VPC, enhancing data privacy and compliance.

The second template sets up the Studio domain, user profiles, and essential apps like JupyterServer and Data Science KernelGateway, ensuring secure access without internet connectivity.

**Together, they support the user journey of deploying SageMaker Studio within a secure, isolated network environment, ensuring data privacy and compliance.**

NOTE: This code sample also accompanies the blog post **[Using Generative AI foundation models in VPC mode with no internet connectivity using Amazon SageMaker JumpStart](https://aws.amazon.com/blogs/machine-learning/use-generative-ai-foundation-models-in-vpc-mode-with-no-internet-connectivity-using-amazon-sagemaker-jumpstart/)**.

## Deployment Walkthrough 🛠️

To deploy this solution, you'll need to execute a series of commands using the AWS CLI. Here's a step-by-step guide:

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/aws-samples/sagemaker-studio-admin-iac-templates.git
   cd sagemaker-studio-admin-iac-templates
    ```
2. Install the Make command (if on Mac)
    ```bash
    brew install make
    ```
3. Make sure you have the AWS CLI installed and configured with the necessary permissions:
    ```bash
    make install-aws-cli
    ```
4. Deploy the CloudFormation templates provided in the project:
    ```bash
    make deploy-cfn-from-local FOLDER=studio-classic-vpconly
    ```
## Additional Security Measures 🔒

Even though this sample configures SageMaker Studio in a VPC with no internet access, you may want to add further restrictions to network traffic using network ACLs and security groups. To learn more about network ACLs and security groups, read [Compare security groups and network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html).

This sample does not modify the default network ACLs associated with the subnets. The default network ACL is configured to allow all traffic to flow in and out of the subnets with which it is associated. If you want to restrict the subnets to accept only the traffic originated from the VPC SageMaker Studio is configured to use, please note the following:

- If you change the network ACLs to allow traffic to/from the VPC CIDR only, the connectivity to services via interface VPC endpoints will not be affected, as interface VPC endpoints create an elastic network interface inside the VPC subnets. However, the gateway VPC endpoint for S3 does not create elastic network interfaces. Instead, the gateway VPC endpoints add prefix lists to the route tables and the traffic from SageMaker Studio to Amazon S3, which is going to the public address range for Amazon S3 in the current region, will not match the network ACL rules that allow traffic to/from the VPC CIDR only. As a result, you will not be able to see the list of SageMaker JumpStart models when you launch SageMaker Studio.

### Options to Address the Issue:

1. Add outbound/inbound rules to allow traffic to/from all IP address ranges for Amazon S3 in the region as documented [here](https://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html).
2. For Amazon S3, use interface VPC endpoints instead of gateway VPC endpoints. By using interface VPC endpoints, you can restrict the network ACLs without adding IP address ranges. However, note that interface VPC endpoints are chargeable. For more information, read the blog post [Choosing Your VPC Endpoint Strategy for Amazon S3](https://aws.amazon.com/blogs/architecture/choosing-your-vpc-endpoint-strategy-for-amazon-s3/).

In addition to restricting network ACLs, if you want to restrict outbound traffic from SageMaker Studio using security groups, you can add an outbound rule to the security group to allow traffic to the VPC CIDR only. If you are using gateway S3 endpoints, you should configure the security group to allow outbound traffic to all IP ranges for Amazon S3 in the current region.

## Clean Up

You will be creating several billable resources in your AWS account. After experimentation, make sure you follow the steps in `CLEANUP.md` to remove all resources created. If you encounter any issues when deleting the resources, troubleshoot the issues by following the [AWS CloudFormation troubleshooting guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/troubleshooting.html).
