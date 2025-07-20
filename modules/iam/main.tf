resource "aws_iam_role" "eks_role" {
  name = "${var.env}-${var.name}-eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.env}-${var.name}-eks-cluster-role"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_group" {
  name = "${var.env}-${var.name}-eks-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.env}-${var.name}-eks-node-group-role"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_core" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "node_group" {
  name = "${var.env}-${var.name}-node-group-profile"
  role = aws_iam_role.eks_node_group.name
}

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
#   role       = aws_iam_role.eks_node_group.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }


resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_oidc_role" {
  name = "${var.env}-${var.name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.repo_name}:*"
        }
      }
    }]
  })

  tags = {
    Environment = var.env
    App         = var.name
  }
}

resource "aws_iam_policy" "github_secrets_policy" {
  name        = "${var.env}-${var.name}-github-secrets-policy"
  description = "Allow GitHub Actions to read SecretsManager secret"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:/wtv/dev/db*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "github_secrets" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = aws_iam_policy.github_secrets_policy.arn
}

resource "aws_iam_policy" "github_describe_cluster" {
  name        = "${var.env}-${var.name}-github-describe-cluster"
  description = "Allow GitHub Actions to describe EKS cluster for kubeconfig setup"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = "arn:aws:eks:${var.region}:${var.aws_account_id}:cluster/${var.env}-${var.name}-cluster"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_github_describe_cluster" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = aws_iam_policy.github_describe_cluster.arn
}

resource "aws_iam_policy" "github_list_clusters" {
  name = "${var.env}-${var.name}-github-list-clusters"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "eks:ListClusters"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_list_clusters" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = aws_iam_policy.github_list_clusters.arn
}