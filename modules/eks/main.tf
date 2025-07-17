resource "aws_eks_cluster" "eks" {
  name     = "${var.env}-${var.name}-cluster"
  role_arn = var.eks_role_arn
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }
  version = var.k8s_version
  tags = {
    Name        = "${var.name}-eks"
    Environment = var.env
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.env}-${var.name}-node-group"
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = var.instance_types
  capacity_type  = var.capacity_type

  ami_type  = var.ami_type
  disk_size = 20

  tags = {
    Name        = "${var.env}-${var.name}-node-group"
    Environment = var.env
  }

  depends_on = [aws_eks_cluster.eks]
}