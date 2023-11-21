# EC2 Launch template
resource "aws_launch_template" "fullnode_ec2_template" {
  name_prefix   = "fullnode_ec2_launch_template"
  image_id      = "ami-0b4bb4751e9a8fbdb"
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

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file(var.ssh_public_key)
}

# Autoscaling group
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