output "eks_role_arn" {
  value = aws_iam_role.eks_role.arn
}

output "eks_role_name" {
  value = aws_iam_role.eks_role.name
}

output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_group.arn
}

output "eks_node_group_profile_name" {
  value = aws_iam_instance_profile.node_group.name
}