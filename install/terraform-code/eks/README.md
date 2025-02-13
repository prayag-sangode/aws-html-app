# Deploying an EKS Cluster using Terraform

This guide explains how to deploy an AWS Elastic Kubernetes Service (EKS) cluster using Terraform. The Terraform configuration consists of the following files:

## File Structure

```
.
├── provider.tf          # Configures Terraform AWS provider
├── main.tf              # Defines the EKS cluster and node group
├── ebs-csi-driver.tf    # Deploys the EBS CSI driver for persistent storage
```

## Execution Sequence

| **Step** | **File**               | **Type**               | **Resource**                                   | **Description** |
|---------|----------------------|----------------------|--------------------------------|----------------------------------------------------------|
| **1** | `provider.tf`       | Provider Setup       | `provider "aws"`               | Configures AWS provider. |
| **2** | `main.tf`           | Create EKS Cluster   | `resource "aws_eks_cluster" "eks"` | Creates the EKS cluster. |
| **3** | `main.tf`           | Create Node Group    | `resource "aws_eks_node_group" "eks_nodes"` | Defines worker node group. |
| **4** | `ebs-csi-driver.tf` | IAM Role for EBS CSI | `resource "aws_iam_role" "ebs_csi_driver"` | Creates IAM role for the EBS CSI driver. |
| **5** | `ebs-csi-driver.tf` | Attach IAM Policies  | `aws_iam_role_policy_attachment "AmazonEBSCSIDriverPolicy"` | Attaches required policies. |
| **6** | `ebs-csi-driver.tf` | Deploy EBS CSI Addon | `resource "aws_eks_addon" "ebs_csi_driver"` | Installs EBS CSI driver in the EKS cluster. |

## Steps to Deploy

1. **Initialize Terraform**
   ```sh
   terraform init
   ```

2. **Plan the Deployment**
   ```sh
   terraform plan
   ```

3. **Apply the Configuration**
   ```sh
   terraform apply -auto-approve
   ```

4. **Verify the Deployment**
   ```sh
   aws eks --region <region> describe-cluster --name <cluster-name>
   ```

5. **Connect to the Cluster**
   ```sh
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   kubectl get nodes
   ```

## Cleanup

To destroy all resources:
```sh
terraform destroy -auto-approve
```

## Sequence of execution Terraform code:

| **Step** | **Type**               | **Resource**                                   | **Description** |
|---------|----------------------|--------------------------------|----------------------------------------------------------|
| **1** | Provider Setup       | `provider "aws"`               | Configures AWS provider in `us-east-1`. |
| **2** | Fetch Default VPC    | `data "aws_vpc" "default"`     | Retrieves the default VPC in the region. |
| **3** | Fetch Subnets        | `data "aws_subnets" "default"` | Retrieves all subnets within the default VPC. |
| **4** | Fetch Security Group | `data "aws_security_group" "default"` | Retrieves the default security group within the default VPC. |
| **5** | Fetch Subnets in AZ  | `data "aws_subnet" "az1"` & `data "aws_subnet" "az2"` | Retrieves subnets in `us-east-1a` and `us-east-1b` availability zones. |
| **6** | IAM Role for EKS Cluster | `resource "aws_iam_role" "eks_cluster"` | Creates IAM role for the EKS cluster. |
| **7** | Attach IAM Policies  | `aws_iam_role_policy_attachment` (Cluster Policies) | Attaches `AmazonEKSClusterPolicy` & `AmazonEKSServicePolicy` to the EKS cluster role. |
| **8** | Create EKS Cluster   | `resource "aws_eks_cluster" "my_cluster"` | Creates the EKS cluster using subnets and security group from previous steps. |
| **9** | IAM Role for Node Group | `resource "aws_iam_role" "eks_node"` | Creates IAM role for the worker nodes. |
| **10** | Attach IAM Policies  | `aws_iam_role_policy_attachment` (Node Policies) | Attaches `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, and `AmazonEC2ContainerRegistryReadOnly` to the node role. |
| **11** | Create EKS Node Group | `resource "aws_eks_node_group" "my_node_group"` | Creates an EKS node group using default subnets and the node IAM role. |
| **12** | Provider TLS         | `provider "tls"`               | Fetches the OIDC thumbprint for authentication. |
| **13** | Fetch OIDC Certificate | `data "tls_certificate" "oidc"` | Retrieves TLS certificate for OIDC provider. |
| **14** | IAM Role for EBS CSI Driver | `resource "aws_iam_role" "ebs_csi_driver"` | Creates IAM role for the EBS CSI driver. |
| **15** | Assume Role Policy   | `data "aws_iam_policy_document" "ebs_csi_driver_assume_role"` | Defines role assumption policy for the EBS CSI driver. |
| **16** | Attach IAM Policies  | `aws_iam_role_policy_attachment "AmazonEBSCSIDriverPolicy"` | Attaches the `AmazonEBSCSIDriverPolicy` to the EBS CSI driver IAM role. |
| **17** | Create OIDC Provider | `resource "aws_iam_openid_connect_provider" "eks"` | Creates an OIDC provider for the EKS cluster. |
| **18** | Create Kubernetes Service Account | `resource "kubernetes_service_account" "ebs_csi_controller_sa"` | Creates a Kubernetes service account for the EBS CSI driver. |
| **19** | EKS Addon - EBS CSI Driver | `resource "aws_eks_addon" "ebs_csi_driver"` | Installs the EBS CSI driver add-on in the EKS cluster. |
| **20** | Fetch EKS Cluster Data | `data "aws_eks_cluster" "my_cluster"` | Retrieves details about the created EKS cluster. |
| **21** | Fetch Cluster Auth   | `data "aws_eks_cluster_auth" "my_cluster"` | Fetches authentication details for the cluster. |
| **22** | Configure Kubernetes Provider | `provider "kubernetes"` | Configures the Kubernetes provider using the EKS cluster endpoint and token. |
| **23** | Outputs              | `output "cluster_endpoint"`, `output "cluster_name"`, etc. | Prints key values such as cluster endpoint, name, and node group name. |


