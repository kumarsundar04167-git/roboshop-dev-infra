resource "aws_ssm_parameter" "backend_alb_listener_arn" {
  name        = "/${var.project}/${var.environment}/backend_alb_listener_arn"
  description = "The ARN of the backend application load balancer listener"
  type        = "String"
  value       = aws_lb_listener.backend_alb_http.arn
  overwrite = true
}