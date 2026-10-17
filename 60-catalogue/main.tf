resource "aws_instance" "catalogue" {
  ami                  = local.ami_id
  instance_type        = "t3.micro" # Cost-effective instance type
  subnet_id            = local.private_subnet_id
  vpc_security_group_ids = [local.catalogue_sg_id]

  tags = merge(
    var.catalogue_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-catalogue"
    }
  )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]


connection {
      type        = "ssh"
      user        = "ec2-user"
      password    = "DevOps321"
      host        = aws_instance.catalogue.private_ip
    }

    provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }


    provisioner "remote-exec" {
     inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue ${var.environment} ${var.app_version}"
    ]
  }
}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped" # Switch to "running" to start it back up
  depends_on = [terraform_data.catalogue]
}

resource "aws_ami_from_instance" "catalogue" {
  name               ="${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
  source_instance_id = aws_instance.catalogue.id 
  depends_on = [aws_ec2_instance_state.catalogue]

  tags = merge(
    var.catalogue_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
    }
  )
}

resource "aws_launch_template" "catalogue" {
  name = "${local.common_name}-catalogue"
  image_id = "aws_ami_from_instance.catalogue.id"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  vpc_security_group_ids = [local.catalogue_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
        }
    ) 
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
        }
    ) 
  }

  

    tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
        }
    ) 
  
}


# Create the Target Group
resource "aws_lb_target_group" "catalogue" {
  name        = "${local.common_name}-catalogue"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = "local.vpc_id" # Replace with your VPC ID
  target_type = "instance"               # Options: instance, ip, lambda, alb
  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200" # Expected HTTP response code
  }

  # Best practice: avoids downtime during replacements
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
        }
    ) 
  
}

resource "aws_autoscaling_group" "catalogue" {
  name_prefix         = "${local.common_name}-catalogue"
  vpc_zone_identifier = [local.private_subnet_id] # Replace with your private subnets
  target_group_arn = [aws_lb_target_group.catalogue.arn]

  min_size         = 1
  max_size         = 10
  desired_capacity = 2
  health_check_type   = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }

  # Best practice: Ignore capacity changes if you use dynamic scaling policies
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

   instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
   
   dynamic "tag" {
    for_each = merge(
       local.common_tags,
     {
        Name = 
     }
    )
    content {
     key                 = "tag.key"
     value               = "atag.value"
     propagate_at_launch = true
    }
   
     timeouts {
        delete = "15m"
     }
   }  
}

resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${local.common_name}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name 
  policy_type            = "TargetTrackingScaling"  
  estimated_instance_warmup = 120 

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0 # Target 75% CPU utilization
  }
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend_alb-${var.environment}.${var.domain_name}"]
    }
  }
}

resource "terraform_data" "catalogue_delete" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  depends_on = [aws_autoscaling_policy.catalogue]

  # executes where terraform is running
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
  }
}
