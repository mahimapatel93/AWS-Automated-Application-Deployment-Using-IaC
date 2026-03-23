output "vpc_id" {
  value = aws_vpc.cheetah_infra_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.cheetah_infra_vpc.cidr_block
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnets : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}