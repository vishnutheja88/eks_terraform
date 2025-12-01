aws_region               = "us-west-2"
vpc_cidr                 = "10.3.0.0/16"
public_subnet_cidrs      = ["10.3.1.0/24", "10.3.2.0/24"]
private_subnet_cidrs     = ["10.3.3.0/24", "10.3.4.0/24"]
availability_zones       = ["us-west-2a", "us-west-2b"]
cluster_name             = "us-west-2-test-cluster"
node_group_name          = "us-west-2-test-nodegroup"
eks_version              = "1.32"
node_group_instance_type = "t3.medium"
desired_size             = 2
max_size                 = 3
min_size                 = 1

aws_profile              = "vamsi"