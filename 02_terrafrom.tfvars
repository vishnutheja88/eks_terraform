aws_region               = "us-west-1"
vpc_cidr                 = "10.1.0.0/16"
public_subnet_cidrs      = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs     = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones       = ["us-west-1a", "us-west-1b", "us-west-1c"]
cluster_name             = "us-west-1-test-cluster"
node_group_name          = "us-west-1-test-nodegroup"
eks_version              = "1.32"
node_group_instance_type = "t3.medium"
desired_size             = 2
max_size                 = 3
min_size                 = 1

aws_profile              = "vamsi"