resource "aws_ssm_parameter" "frontend_alb_listener_arn" {
  name        = "/${var.project}/${var.environment}/frontend_alb_listener_arn"
  description = "The ARN of the frontend application load balancer listener"
  type        = "String"
  value       = aws_lb_listener.frontend_alb_https.arn
  overwrite = true
}