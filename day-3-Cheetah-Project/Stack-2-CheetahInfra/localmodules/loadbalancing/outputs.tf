output "nlb_tg_arn" {
  value = aws_lb_target_group.nlb_target_group.arn
}

output "nlb_dns_endpoint" {
  value = aws_lb.net_lb.dns_name
}

output "alb_tg_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}

output "alb_dns_endpoint" {
  value = aws_lb.alb.dns_name
}