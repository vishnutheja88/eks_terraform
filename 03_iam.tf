# Create an IAM role for the EKS cluster
resource "aws_iam_role" "eks-cluster-role" {
    name = "eks-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
            }
        ]
    }) 
}

# Attach the AmazonEKSClusterPolicy to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks-cluster-role.name
}

# EKS node group role
resource "aws_iam_role" "eks-nodegroup-role" {
    name = "eks-nodegroup-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            }
        ]
    }) 
}

# Attach the AmazonEKSWorkerNodePolicy to the EKS node group role
resource "aws_iam_role_policy_attachment" "eks-worker-node-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.eks-nodegroup-role.name
}

# Attach the AmazonEKS_CNI_Policy to the EKS node group role
resource "aws_iam_role_policy_attachment" "eks-cni-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.eks-nodegroup-role.name
}
# Attach the AmazonEC2ContainerRegistryReadOnly to the EKS node group role
resource "aws_iam_role_policy_attachment" "eks-ecr-readonly-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.eks-nodegroup-role.name
}