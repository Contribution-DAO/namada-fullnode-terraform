# VPC
resource "aws_vpc" "fullnode_main" {
  cidr_block = "10.0.0.0/23"
  tags = {
    Name = var.vpc_name
  }
}

# Public subnet 01
resource "aws_subnet" "fullnode_subnet_01" {
  vpc_id                  = aws_vpc.fullnode_main.id
  cidr_block              = "10.0.0.0/27"
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_01_az
  tags = {
    Name = var.subnet_01_name
  }
}

# Public subnet 02
resource "aws_subnet" "fullnode_subnet_02" {
  vpc_id                  = aws_vpc.fullnode_main.id
  cidr_block              = "10.0.0.32/27"
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_02_az
  tags = {
    Name = var.subnet_02_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "fullnode_gw" {
  vpc_id = aws_vpc.fullnode_main.id
}

# route table for public subnet - connecting to Internet gateway
resource "aws_route_table" "fullnode_rt_public" {
  vpc_id = aws_vpc.fullnode_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fullnode_gw.id
  }
}

# Associate the route table with public subnet
resource "aws_route_table_association" "fullnode_rta1" {
  subnet_id      = aws_subnet.fullnode_subnet_01.id
  route_table_id = aws_route_table.fullnode_rt_public.id
}

resource "aws_route_table_association" "fullnode_rta2" {
  subnet_id      = aws_subnet.fullnode_subnet_02.id
  route_table_id = aws_route_table.fullnode_rt_public.id
}

# Load balance setup
resource "aws_lb" "fullnode_lb" {
  name               = "fullnode-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.fullnode_sg_elb.id]
  subnets            = [aws_subnet.fullnode_subnet_01.id, aws_subnet.fullnode_subnet_02.id]
  depends_on         = [aws_internet_gateway.fullnode_gw]
}

resource "aws_lb_target_group" "fullnode_lb_tg" {
  name     = "fullnode-lb-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.fullnode_main.id
}

resource "aws_lb_listener" "fullnode_lb_endpoint" {
  load_balancer_arn = aws_lb.fullnode_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fullnode_lb_tg.arn
  }
}