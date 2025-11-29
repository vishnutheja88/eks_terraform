# Terraform EKS Deployment Steps

## 1. Initialize and Plan

```sh
terraform init
terraform plan -var-file="02_terraform.tfvars"
terraform apply -var-file="02_terraform.tfvars"
```
## 2. Infrastructure Components Created (in order)
Step 1: Provider & Variables (00_provider.tf, 01_variable.tf)
        AWS provider configuration
        All variable definitions with defaults
Step 2: VPC Infrastructure (06_vpc.tf)
        VPC with CIDR 10.1.0.0/16
        Internet Gateway
        2 Public subnets (10.1.1.0/24, 10.1.2.0/24)
        2 Private subnets (10.1.3.0/24, 10.1.4.0/24)
        NAT Gateway with Elastic IP
        Route tables and associations
Step 3: IAM Roles (03_iam.tf)
        EKS cluster service role with AmazonEKSClusterPolicy
        EKS node group role with:
        AmazonEKSWorkerNodePolicy
        AmazonEKS_CNI_Policy
        AmazonEC2ContainerRegistryReadOnly
Step 4: EKS Cluster & OIDC (05_eks_cluster.tf)
        EKS cluster in both public and private subnets
        Node group in private subnets only
        TLS certificate data source
        OIDC provider for IRSA
        Cluster autoscaler IAM role and policy

## 3. Post-Deployment Steps

Configure kubectl:
```bash
aws eks update-kubeconfig --region us-east-1 --name my-test-cluster
``` 

Deploy Cluster Autoscaler:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn=<AUTOSCALER_ROLE_ARN>
```

## 4. Key Outputs
EKS cluster endpoint
Cluster autoscaler IAM role ARN
VPC and subnet IDs



# EKS Terraform Infrastructure

This repository contains Terraform configuration files to deploy a production-ready Amazon EKS cluster with autoscaling capabilities.

## File Structure

### Configuration Files

| File | Description | Resources Created |
|------|-------------|-------------------|
| `00_provider.tf` | AWS provider configuration | - AWS provider with region and profile |
| `01_variable.tf` | Variable definitions | - All input variables with defaults |
| `02_terraform.tfvars` | Variable values | - Actual values for deployment |
| `03_iam.tf` | IAM roles and policies | - EKS cluster role<br>- EKS node group role<br>- Policy attachments |
| `04_node_group.tf` | Node group configuration | - Currently empty |
| `05_eks_cluster.tf` | EKS cluster and OIDC | - EKS cluster<br>- EKS node group<br>- OIDC provider<br>- Cluster autoscaler IAM role |
| `06_vpc.tf` | VPC networking | - VPC<br>- Internet Gateway<br>- Public/Private subnets<br>- NAT Gateway<br>- Route tables |
| `07_autoscaler.tf` | Autoscaler configuration | - Currently empty |

## Infrastructure Components

### 1. VPC Infrastructure (`06_vpc.tf`)
- **VPC**: `10.1.0.0/16` CIDR block
- **Public Subnets**: 2 subnets (`10.1.1.0/24`, `10.1.2.0/24`)
- **Private Subnets**: 2 subnets (`10.1.3.0/24`, `10.1.4.0/24`)
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access
- **Route Tables**: Separate routing for public and private subnets

### 2. IAM Roles (`03_iam.tf`)
- **EKS Cluster Role**: Service role for EKS cluster operations
- **EKS Node Group Role**: EC2 role for worker nodes with CNI and ECR permissions

### 3. EKS Cluster (`05_eks_cluster.tf`)
- **EKS Cluster**: Kubernetes control plane
- **Node Group**: Managed worker nodes in private subnets
- **OIDC Provider**: For IAM Roles for Service Accounts (IRSA)
- **Cluster Autoscaler Role**: IAM role for automatic node scaling

## Deployment Steps

### Prerequisites
- AWS CLI configured
- Terraform installed
- kubectl installed

### 1. Initialize Terraform
```bash
terraform init
```
##  2. Plan Deployment
```bash
terraform plan -var-file="02_terraform.tfvars"
```

## 3. Deploy Infrastructure
```bash
terraform apply -var-file="02_terraform.tfvars"
```

## 4. Configure kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name my-test-cluster
```

## 5. Deploy Cluster Autoscaler
```bash
# Download and apply cluster autoscaler
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# Annotate service account with IAM role
kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn=$(terraform output -raw eks_cluster_autoscaler_arn)
```

## Resource Creation Order
Provider Configuration → AWS provider setup
VPC Infrastructure → Network foundation
IAM Roles → Security permissions
EKS Cluster → Kubernetes control plane
Node Group → Worker nodes
OIDC Provider → Service account authentication
Autoscaler Role → Automatic scaling permissions

## Cleanup
```bash
terraform destroy -var-file="02_terraform.tfvars"
```