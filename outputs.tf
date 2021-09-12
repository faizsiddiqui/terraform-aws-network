output "aws_region" {
  value = var.aws_region
}

output "aws_vpc_id" {
  value = aws_vpc.vpc.id
}

output "aws_vpc_ipv4_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "aws_vpc_ipv6_cidr" {
  value = aws_vpc.vpc.ipv6_cidr_block
}
