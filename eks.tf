resource "aws_eks_cluster" "cluster" {
  name     = var.eks_cluster_name
  version =  1.28
  role_arn = aws_iam_role.eks-cluster.arn
  vpc_config {
    subnet_ids = [
        aws_subnet.private[0].id,
        aws_subnet.private[1].id,
    ]
    security_group_ids = [aws_security_group.additional_sg.id]
    endpoint_private_access = "false"
    endpoint_public_access = "true"
  }

  tags                          =  merge(tomap({
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    
  }),var.resource_tags)

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy-cluster,
  ]

}

resource "aws_eks_addon" "kube" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "kube-proxy"
  # addon_version = "v1.28.2-eksbuild.2"

}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "vpc-cni"
  # addon_version = "v1.15.4-eksbuild.1"

   
}

resource "aws_eks_addon" "credns" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "coredns"
  # addon_version = "v1.10.1-eksbuild.6"
   
}

resource "aws_eks_addon" "ebs" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "aws-ebs-csi-driver"
  # addon_version = "v1.25.0-eksbuild.1"

   
}
resource "aws_security_group" "additional_sg" { 
  name        = "allow_tls"
  description = "Allow eks inbound traffic"
  vpc_id      = aws_vpc.VPC-akhil.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.VPC-akhil.cidr_block]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}
