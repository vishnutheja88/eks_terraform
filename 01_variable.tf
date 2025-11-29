variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-1"
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "public subnets CIDR blocks"
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnets CIDR blocks"
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy resources in"
  default     = ["us-west-1a", "us-west-1b", "us-west-1c"]
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
  default     = "1.32"
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
  default     = "vamsi"
}