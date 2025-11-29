variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "public subnets CIDR blocks"
  default     = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnets CIDR blocks"
  default     = ["192.168.3.0/24", "192.168.4.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy resources in"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-test-cluster"
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
  default     = "my-test-nodegroup"

}

variable "eks_version" {
  description = "The version of EKS to use"
  type        = string
  default     = "1.27"
}
variable "node_group_instance_type" {
  description = "The instance type of the EKS node group"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "The desired size of the EKS node group"
  type        = number
  default     = 2
}
variable "max_size" {
  description = "The maximum size of the EKS node group"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "The minimum size of the EKS node group"
  type        = number
  default     = 1
}
variable "aws_profile" {
  description = "The AWS profile to use"
  type        = string
  default     = "default"
}