output "eks_node_group_role_arn" {
  value = module.iam_eks_cluster.eks_node_group_role_arn
}

output "eks_role_arn" {
  value = module.iam_eks_cluster.eks_role_arn
}