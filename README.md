# ☸️ AWS EKS Cluster Deployment using Terraform

This project automates the complete setup of a **scalable, modular, and highly available** Kubernetes infrastructure on AWS using **Terraform**.

---

## 🚀 Project Overview

- 🔁 Deploys an **EKS cluster** using the official [terraform-aws-eks](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) module.
- 🌐 Sets up a full **networking stack** with the [terraform-aws-vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module.
- 🛡️ Separates **private and public subnets** across multiple AZs.
- 🌍 Ensures **internet access** for private subnets via a **NAT Gateway**.
- ☁️ Uses **self-managed EC2 worker nodes** in multiple groups and instance types.
- 🔓 Tags subnets and resources correctly for **Kubernetes LoadBalancer** support.
- 📡 Connects to the Kubernetes API from Terraform using the **Kubernetes provider**.

---

## 📁 Project Structure

```bash
.
- ├── eks-cluster.tf             # EKS cluster module
- ├── vpc.tf                     # VPC & subnets (public/private)
- ├── terraform.tfvars           # Custom variable values
- ├── update-ip.sh               # IP auto-injection helper script
- ├── kubeconfig_myapp-eks-cluster (generated)
```
## Terraform Modules Used
  VPC Module (vpc.tf)
    module "myapp-vpc" {
      source  = "terraform-aws-modules/vpc/aws"
      version = "5.21.0"
    
      cidr = var.vpc_cidr_block
      private_subnets = var.private_subnet_cidr_blocks
      public_subnets  = var.public_subnet_cidr_blocks
      azs = data.aws_availability_zones.azs.names
    
      enable_nat_gateway     = true
      single_nat_gateway     = true
      enable_dns_hostnames   = true
    
      public_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/elb"                  = 1
      }
    
      private_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb"         = 1
      }
    }

## EKS Cluster (eks-cluster.tf)
    module "eks" {
      source  = "terraform-aws-modules/eks/aws"
      version = "20.36.0"
    
      cluster_name    = "myapp-eks-cluster"
      cluster_version = "1.31"
    
      vpc_id      = module.myapp-vpc.vpc_id
      subnet_ids  = module.myapp-vpc.private_subnets
    
      self_managed_node_groups = {
        worker_group_1 = {
          instance_type        = "t2.micro"
          asg_desired_capacity = 2
          min_size             = 1
          max_size             = 3
        },
        worker_group_2 = {
          instance_type        = "t2.medium"
          asg_desired_capacity = 1
          min_size             = 1
          max_size             = 2
        }
      }
    }

## Kubernetes Provider
  provider "kubernetes" {
  host                   = data.aws_eks_cluster.myapp-cluster.endpoint
  token                  = data.aws_eks_cluster_auth.myapp-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

## terraform.tfvars (Example)
vpc_cidr_block               = "10.0.0.0/16"
private_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidr_blocks   = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
avail_zone                  = "eu-west-3b"
env_prefix                  = "dev"
my_ip                       = "102.18.X.X/32"
instance_type               = "t2.micro"
public_key_location         = "~/.ssh/id_rsa.pub"
ssh_key_private             = "~/.ssh/id_rsa"

## kubeconfig Setup (optional)
kubeconfig_myapp-eks-cluster

You can also export config to use kubectl: export KUBECONFIG=./kubeconfig_myapp-eks-cluster

## Key Learnings

    ✅ Built modular, reusable and scalable IaC architecture
    ✅ Mastered Terraform's integration with AWS and Kubernetes
    ✅ Learned advanced networking practices (AZs, NAT Gateways, subnet tagging)
    ✅ Designed for high availability across multiple availability zones
    ✅ Used EKS modules and providers for complete automation

Initialize Terraform
terraform init

Validate Configuration
terraform validate

Review Infrastructure Plan
terraform plan

Test Kubernetes Access
kubectl get nodes
kubectl get pods -A


Security Notes

    Only your IP is allowed via my_ip in the default security group.
    Use Terraform Cloud or a backend (S3 + DynamoDB) for team collaboration and state locking.
    
Author
Fabien Andrianambinintsoa
DevOps Engineer | Kubernetes | AWS | Terraform
🔗 LinkedIn : www.linkedin.com/in/fabien-andrianambinintsoa
