resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-test"
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = aws_subnet.private[*].id
  instance_types  = ["t3.medium"]
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND"
  disk_size       = "20"
  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key              = aws_key_pair.kyc_app_public_key.key_name 
    
  }
  update_config {
    max_unavailable = 1
  }
  tags_all = {
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled" = "true"
  }
    lifecycle {
    create_before_destroy = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-node,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds,
  ]
}

