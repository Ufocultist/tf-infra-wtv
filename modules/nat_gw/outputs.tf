output "nat_gateway_id" {
  value = aws_nat_gateway.ng[*].id
}