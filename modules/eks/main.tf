resource "aws_security_group" "eks_control_plane" {
  name_prefix = "${var.env}-${var.name}-eks-controlplane-"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.env}-${var.name}-eks-control-plane-sg"
    Environment = var.env
  }
}

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.env}-${var.name}-eks-nodes-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.env}-${var.name}-eks-node-sg"
    Environment = var.env
  }
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "${var.env}-${var.name}-cluster"
  role_arn = var.eks_role_arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_control_plane.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  version = var.k8s_version

  tags = {
    Name        = "${var.name}-eks"
    Environment = var.env
  }
}

# EKS Node Group
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
  ami_type       = var.ami_type
  disk_size      = 20

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "${var.env}-${var.name}-node-group"
    Environment = var.env
  }

  depends_on = [aws_eks_cluster.eks]
}

# Control Plane <--> Control Plane
resource "aws_security_group_rule" "control_plane_etcd_peer" {
  description              = "Allow etcd peer communication within control plane"
  type                     = "ingress"
  from_port                = 2380
  to_port                  = 2380
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_control_plane.id
}

resource "aws_security_group_rule" "control_plane_etcd_client" {
  description              = "Allow etcd client access within control plane"
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_control_plane.id
}

resource "aws_security_group_rule" "control_plane_internal_tcp" {
  description              = "Allow all TCP within control plane SG"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_control_plane.id
}

# Control Plane Ingress from Workers
resource "aws_security_group_rule" "control_plane_from_workers_kube_api" {
  description              = "Allow kube-apiserver access from workers"
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "control_plane_from_workers_icmp" {
  description              = "Allow ICMP from workers"
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "control_plane_from_workers_typha" {
  description              = "Allow Typha communication from workers"
  type                     = "ingress"
  from_port                = 5473
  to_port                  = 5473
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "control_plane_from_workers_bgp" {
  description              = "Allow BGP from workers"
  type                     = "ingress"
  from_port                = 179
  to_port                  = 179
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "control_plane_from_workers_kubelet" {
  description              = "Allow kubelet/scheduler/controller-manager ports from workers"
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10259
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Control Plane Egress to Workers
resource "aws_security_group_rule" "control_plane_to_workers_kubelet" {
  description              = "Allow control plane to talk to worker kubelet"
  type                     = "egress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Workers Ingress from Control Plane
resource "aws_security_group_rule" "workers_from_control_plane" {
  description              = "Allow control plane to communicate with nodes"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_control_plane.id
}

# Workers VXLAN (self)
resource "aws_security_group_rule" "workers_vxlan" {
  description              = "Allow VXLAN (Calico overlay networking) between workers"
  type                     = "ingress"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Workers DNS from Anywhere
resource "aws_security_group_rule" "workers_dns_ingress" {
  description = "Allow DNS (from anywhere)"
  type        = "ingress"
  from_port   = 53
  to_port     = 53
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}

# Workers Egress
resource "aws_security_group_rule" "workers_dns_egress" {
  description = "Allow DNS lookup to outside"
  type        = "egress"
  from_port   = 53
  to_port     = 53
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "workers_typha_egress" {
  description = "Allow outbound Typha"
  type        = "egress"
  from_port   = 5473
  to_port     = 5473
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "workers_all_egress" {
  description = "Allow all outbound traffic from workers"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "workers_egress_kubeapi" {
  description              = "Allow outbound to kube-apiserver"
  type                     = "egress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_control_plane.id
}
