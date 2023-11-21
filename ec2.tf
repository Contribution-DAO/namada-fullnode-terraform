# EC2 Launch template
resource "aws_launch_template" "fullnode_ec2_template" {
  name_prefix   = "fullnode_ec2_launch_template"
  image_id      = "ami-0b4bb4751e9a8fbdb" //Ubuntu 20.04
  instance_type = var.ec2_instance_type
  key_name      = aws_key_pair.ssh_key.key_name
  user_data = base64encode(templatefile(var.user_data_file, {
    namada_tag      = var.namada_tag,
    cbft            = var.cbft,
    namada_chain_id = var.namada_chain_id
  }))

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.ec2_disk_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.fullnode_subnet_01.id
    security_groups             = [aws_security_group.fullnode_sg_ec2.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "fullnode-instance"
    }
  }
}

# Loading key pair for ssh 
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file(var.ssh_public_key)
}

# Autoscaling group configuration
resource "aws_autoscaling_group" "fullnode_asg" {
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  # Connect to the target group
  target_group_arns = [aws_lb_target_group.fullnode_lb_tg.arn]

  vpc_zone_identifier = [
    aws_subnet.fullnode_subnet_01.id,
    aws_subnet.fullnode_subnet_02.id
  ]

  launch_template {
    id      = aws_launch_template.fullnode_ec2_template.id
    version = "$Latest"
  }
  
}
# CPU Utilization Scaling Policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale_out_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.fullnode_asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale_in_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.fullnode_asg.name
}

# CloudWatch CPU Utilization Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.fullnode_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_utilization" {
  alarm_name          = "low-cpu-utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.fullnode_asg.name
  }
}
