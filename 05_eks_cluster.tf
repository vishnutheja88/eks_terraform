# EKS Cluster

resource "aws_eks_cluster" "eks-cluster" {
    name = var.cluster_name
    role_arn = aws_iam_role.eks-cluster-role.arn
    version = var.eks_version
    vpc_config {
        subnet_ids = concat(
            aws_subnet.k8s-public-subnets[*].id,
            aws_subnet.k8s-private-subnets[*].id
        )
    }
    depends_on = [ aws_iam_role_policy_attachment.eks-cluster-policy ]
    
}


# EKS Node Group
resource "aws_eks_node_group" "eks-nodegroup" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    node_group_name = var.node_group_name
    node_role_arn = aws_iam_role.eks-nodegroup-role.arn
    subnet_ids = aws_subnet.k8s-private-subnets[*].id
    scaling_config {
        desired_size = var.desired_size
        max_size = var.max_size
        min_size = var.min_size
    }
    instance_types = [ var.node_group_instance_type ]
    capacity_type = "ON_DEMAND"
    depends_on = [ 
        aws_iam_role_policy_attachment.eks-worker-node-policy,
        aws_iam_role_policy_attachment.eks-cni-policy,
        aws_iam_role_policy_attachment.ecr-policy-readonly-policy
     ]

     labels = {
       "node" = "test-cluster-node"
     }
}

#get eks cluster certificate
data "tls_certificate" "eks-cluster-cert" {
    url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

# create OPENID connect provider
resource "aws_iam_openid_connect_provider" "eks-cluster-oidc" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks-cluster-cert.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer

    tags = {
      "name" = "${var.cluster_name}-oidc-provider"
    }
}

# eks cluster autoscaler iam role
data "aws_iam_policy_document" "eks-cluster-autoscaler-assume-policy" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect = "Allow"
        principals {
            type = "Federated"
            identifiers = [aws_iam_openid_connect_provider.eks-cluster-oidc.arn]
        }
        condition {
            test = "StringEquals"
            variable = "${replace(aws_iam_openid_connect_provider.eks-cluster-oidc.url, "https://", "")}:sub"
            values = ["system:serviceaccount:kube-system:cluster-autoscaler"]
        }
    }
}

resource "aws_iam_role" "eks_cluster_autoscaler_role" {
    assume_role_policy = data.aws_iam_policy_document.eks-cluster-autoscaler-assume-policy.json
    name = "${var.cluster_name}-cluster-autoscaler-role"
    tags = {
        "Name" = "${var.cluster_name}-cluster-autoscaler-role"
    }
}

resource "aws_iam_policy" "eks_cluster_autoscaler_policy" {
    name = "${var.cluster_name}-cluster-autoscaler-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "autoscaling:DescribeAutoScalingGroups",
                    "autoscaling:DescribeAutoScalingInstances",
                    "autoscaling:DescribeLaunchConfigurations",
                    "autoscaling:DescribeTags",
                    "autoscaling:SetDesiredCapacity",
                    "autoscaling:TerminateInstanceInAutoScalingGroup",
                    "ec2:DescribeLaunchTemplateVersions"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_policy" {
    policy_arn = aws_iam_policy.eks_cluster_autoscaler_policy.arn
    role = aws_iam_role.eks_cluster_autoscaler_role.name
}

output "eks_cluster_autoscaler_arn" {
    value = aws_iam_role.eks_cluster_autoscaler_role.arn
}
