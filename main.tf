terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28.0"
    }
  }
  required_version = ">= 1.2.4"
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-east-1"
  access_key  = "AKIA3CP3ITEC4YMNFFGH"
  secret_key  = "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"

}

locals {
  aws_ami_linux = "ami-0406808750276369f"
  aws_ami_windows = "ami-0e369d64fc4e0ba34"
}

data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    # values = ["CIS CentOS Linux 7 Benchmark v3.1.2.9 - Level 1-*"]
    values = ["CIS CentOS Linux 7 Benchmark v3.1.* - Level 1-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["211372476111"] # CIS
}

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    # values = ["CIS Microsoft Windows Server 2019 Benchmark v1.3.0.1 - Level 1-*"]
    values = ["CIS Microsoft Windows Server 2019 Benchmark v1.3* - Level 1-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["211372476111"] # CIS
}


data "aws_kms_key" "ebs_key" {
  key_id = "alias/aws/ebs"
}

data "aws_ebs_default_kms_key" "current" {}

data "aws_kms_key" "current" {
  key_id = data.aws_ebs_default_kms_key.current.key_arn
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["DigiQal - ${title(lower(var.environment))}"]
  }
}

data "aws_subnet" "util_subnet_a" {
  filter {
    name   = "tag:Name"
    values = ["${lower(var.environment)}-util-subnet-a"]
  }
}

data "aws_subnets" "subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    Environment = var.env
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.subnet.ids)
  id       = each.value
}

data "aws_subnet" "subnet" {
  for_each = toset([for v in data.aws_subnet.subnets : v.tags["Name"]])
  vpc_id   = data.aws_vpc.vpc.id
  tags = {
    Name = each.key
  }
}


data "aws_subnet" "private_subnet_a" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${lower(var.environment)}-private-subnet-a"]
  }
}

data "aws_subnet" "private_subnet_b" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${lower(var.environment)}-private-subnet-b"]
  }
}

data "aws_subnet" "private_subnet_c" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${lower(var.environment)}-private-subnet-c"]
  }
}

data "aws_subnet" "web_subnet_a" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${lower(var.environment)}-web-subnet-a"]
  }
}

data "aws_subnet" "web_subnet_b" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${lower(var.environment)}-web-subnet-b"]
  }
}

data "aws_security_group" "client_vpn" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-Client-VPN"
}

data "aws_security_group" "bastion" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-Bastion"
}

data "aws_security_group" "mongodb" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-Mongo"
}

data "aws_security_group" "opsmanager" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-OpsManager"
}

data "aws_security_group" "elasticsearch" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-Elasticsearch"
}

data "aws_security_group" "app" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-DMP-APP"
}

data "aws_security_group" "web" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-DMP-WEB"
}

data "aws_security_group" "internal_alb" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-DMP-Intenal-ALB"
}

data "aws_security_group" "external_alb" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-DMP-External-ALB"
}

data "aws_security_group" "https" {
  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.environment}-HTTPS-OUT2ANY"
}

data "aws_iam_policy" "cloudwatch_policy" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "ssm_policy" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "ecr_policy" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_instance_profile" "ec2_server_profile" {
  name = "EC2ServerProfile"
}

data "aws_iam_instance_profile" "ec2_app_server_profile" {
  name = "EC2AppServerProfile"
}

data "aws_acmpca_certificate_authority" "digiqal" {
  arn = "arn:aws:acm-pca:ap-east-1:761273030917:certificate-authority/d4f54bb8-3b7b-4dd1-b092-f43400a0d3e9"
}

# data "aws_acmpca_certificate" "app_internal" {
#   arn                       = "arn:aws:acm-pca:ap-east-1:761273030917:certificate-authority/d4f54bb8-3b7b-4dd1-b092-f43400a0d3e9/certificate/3114b50b-801f-43bb-a388-9cc1176a8dd5"
#   certificate_authority_arn = data.aws_acmpca_certificate_authority.digiqal.id
# }

# data "aws_acmpca_certificate" "app" {
#   arn                       = "arn:aws:acm-pca:ap-east-1:761273030917:certificate-authority/d4f54bb8-3b7b-4dd1-b092-f43400a0d3e9/certificate/7a21eb2a-c6ad-4437-a65a-8a416336c98b"
#   certificate_authority_arn = data.aws_acmpca_certificate_authority.digiqal.id
# }

data "aws_acm_certificate" "app_public" {
  domain      = "app.digiqal.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_instance" "bastion_linux" {
  ami                         = local.aws_ami_linux
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnet.util_subnet_a.id
  associate_public_ip_address = false
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_server_profile.name
  user_data = templatefile(
    "scripts/linux-init.tftpl", {
      HOSTNAME = var.bastion_linux["hostname"],
      ENV      = var.env
    }
  )
  private_ip              = var.bastion_linux["private_ip"]
  vpc_security_group_ids  = [data.aws_security_group.bastion.id]
  key_name                = "DigiQal_${var.environment}"
  disable_api_termination = true

  root_block_device {
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  tags = {
    Name        = var.bastion_linux["hostname"]
    Environment = var.environment
    Role        = "Bastion"
  }

  volume_tags = {
    Name        = var.bastion_linux["hostname"]
    Environment = var.environment
    Role        = "Bastion"

  }
}

resource "aws_instance" "bastion_windows" {
  ami                         = local.aws_ami_windows
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnet.util_subnet_a.id
  associate_public_ip_address = false
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_server_profile.name
  user_data = templatefile(
    "scripts/windows-init.tftpl", {
      HOSTNAME = var.bastion_windows["hostname"]
    }
  )
  private_ip              = var.bastion_windows["private_ip"]
  vpc_security_group_ids  = [data.aws_security_group.bastion.id]
  key_name                = "DigiQal_${var.environment}"
  disable_api_termination = true

  root_block_device {
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  tags = {
    Name        = var.bastion_windows["hostname"]
    Environment = var.environment
    Role        = "Bastion"

  }

  volume_tags = {
    Name        = var.bastion_windows["hostname"]
    Environment = var.environment
    Role        = "Bastion"
  }
}

resource "aws_instance" "app" {
  for_each                    = var.app
  ami                         = local.aws_ami_linux
  instance_type               = "c5.2xlarge"
  subnet_id                   = data.aws_subnet.subnet[each.value["subnet"]].id
  associate_public_ip_address = false
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_app_server_profile.name
  user_data = templatefile(
    "scripts/linux-init-ebs.tftpl", {
      HOSTNAME = each.value["hostname"],
      ENV      = var.env
    }
  )
  private_ip              = each.value["private_ip"]
  vpc_security_group_ids  = [data.aws_security_group.app.id, data.aws_security_group.https.id]
  key_name                = "DigiQal_${var.environment}"
  disable_api_termination = true

  root_block_device {
    volume_size           = 130
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 200
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  tags = {
    Name        = each.value["hostname"]
    Environment = var.environment
    Role        = "Application"
  }

  volume_tags = {
    Name        = each.value["hostname"]
    Environment = var.environment
    Role        = "Application"
  }
}


resource "aws_instance" "mongodb" {
  for_each                    = var.mongodb
  ami                         = local.aws_ami_linux
  instance_type               = "t3.xlarge"
  subnet_id                   = data.aws_subnet.subnet[each.value["subnet"]].id
  associate_public_ip_address = false
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_server_profile.name
  user_data = templatefile(
    "scripts/linux-init-ebs.tftpl", {
      HOSTNAME = each.value["hostname"],
      ENV      = var.env
    }
  )
  private_ip              = each.value["private_ip"]
  vpc_security_group_ids  = [data.aws_security_group.mongodb.id, data.aws_security_group.https.id]
  key_name                = "DigiQal_${var.environment}"
  disable_api_termination = true


  root_block_device {
    volume_size           = 130
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 800
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  tags = {
    Name        = each.value["hostname"]
    Environment = var.environment
    Role        = "Database"
  }

  volume_tags = {
    Name        = each.value["hostname"]
    Environment = var.environment
    Role        = "Database"
  }
}

resource "aws_instance" "elasticsearch" {
  for_each                    = var.elasticsearch
  ami                         = local.aws_ami_linux
  instance_type               = "t3.xlarge"
  subnet_id                   = data.aws_subnet.subnet[each.value["subnet"]].id
  associate_public_ip_address = false
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_server_profile.name
  user_data = templatefile(
    "scripts/linux-init-ebs.tftpl", {
      HOSTNAME = each.value["hostname"],
      ENV      = var.env
    }
  )
  private_ip              = each.value["private_ip"]
  vpc_security_group_ids  = [data.aws_security_group.elasticsearch.id, data.aws_security_group.https.id]
  key_name                = "DigiQal_${var.environment}"
  disable_api_termination = true

  root_block_device {
    volume_size           = 130
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 500
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  tags = {
    Name        = each.value["hostname"]
    Environment = var.environment
    Role        = "Elasticsearch"
  }

  volume_tags = {
    Name        = each.value["hostname"]
    Environment = var.environment
    Role        = "Elasticsearch"
  }
}

resource "aws_instance" "opsmanager" {
  ami                         = local.aws_ami_linux
  instance_type               = "t3.xlarge"
  subnet_id                   = data.aws_subnet.private_subnet_a.id
  associate_public_ip_address = false
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_server_profile.name
  user_data = templatefile(
    "scripts/linux-init-ebs.tftpl", {
      HOSTNAME = var.opsmanager["hostname"],
      ENV      = var.env
    }
  )
  private_ip              = var.opsmanager["private_ip"]
  vpc_security_group_ids  = [data.aws_security_group.opsmanager.id, data.aws_security_group.https.id]
  key_name                = "DigiQal_${var.environment}"
  disable_api_termination = true

  root_block_device {
    volume_size           = 130
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 600
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  tags = {
    Name        = var.opsmanager["hostname"]
    Environment = var.environment
    Role        = "Ops Manager"
  }

  volume_tags = {
    Name        = var.opsmanager["hostname"]
    Environment = var.environment
    Role        = "Ops Manager"
  }
}

resource "aws_instance" "stresstest" {
  ami                         = local.aws_ami_windows
  instance_type               = "c5.2xlarge"
  subnet_id                   = data.aws_subnet.private_subnet_a.id
  associate_public_ip_address = false
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_server_profile.name
  user_data = templatefile(
    "scripts/windows-init.tftpl", {
      HOSTNAME = var.stresstest["hostname"],
      ENV      = var.env
    }
  )
  private_ip              = var.stresstest["private_ip"]
  vpc_security_group_ids  = [data.aws_security_group.app.id]
  key_name                = "DigiQal_${var.environment}"
  disable_api_termination = true

  root_block_device {
    volume_size           = 80
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  tags = {
    Name        = var.stresstest["hostname"]
    Environment = var.environment
    Role        = "Stress Test"
  }

  volume_tags = {
    Name        = var.stresstest["hostname"]
    Environment = var.environment
    Role        = "Stress Test"
  }
}

resource "aws_instance" "web" {
  for_each                    = var.web
  ami                         = local.aws_ami_linux
  instance_type               = "t3.medium"
  subnet_id                   = data.aws_subnet.subnet[each.value["subnet"]].id
  associate_public_ip_address = false
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_server_profile.name
  user_data = templatefile(
    "scripts/linux-init-ebs.tftpl", {
      HOSTNAME = each.value["hostname"],
      ENV      = var.env
    }
  )
  private_ip              = each.value["private_ip"]
  vpc_security_group_ids  = [data.aws_security_group.web.id, data.aws_security_group.https.id]
  key_name                = "DigiQal_${var.environment}"
  disable_api_termination = true

  root_block_device {
    volume_size           = 130
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.current.arn
  }

  tags = {
    Name        = each.value["hostname"]
    Environment = var.environment
    Role        = "Web"
  }

  volume_tags = {
    Name        = each.value["hostname"]
    Environment = var.environment
    Role        = "Web"
  }
}

resource "aws_lb_target_group" "app_alb" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200,301"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "DIGIQAL-${var.environment}-APP-ALB"
  port                          = "443"
  protocol                      = "HTTPS"
  protocol_version              = "HTTP1"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  tags = {
    Name = "DIGIQAL-${var.environment}-APP-ALB"
  }

  tags_all = {
    Name = "DIGIQAL-${var.environment}-APP-ALB"
  }

  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id
}

resource "aws_lb_target_group" "web_alb" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200,301"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "DIGIQAL-${var.environment}-WEB-ALB"
  port                          = "443"
  protocol                      = "HTTPS"
  protocol_version              = "HTTP1"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  tags = {
    Name = "DIGIQAL-${var.environment}-WEB-ALB"
  }

  tags_all = {
    Name = "DIGIQAL-${var.environment}-WEB-ALB"
  }

  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "app_alb" {
  for_each         = aws_instance.app
  target_group_arn = aws_lb_target_group.app_alb.id
  target_id        = each.value["id"]
}

resource "aws_lb_target_group_attachment" "web_alb" {
  for_each         = aws_instance.web
  target_group_arn = aws_lb_target_group.web_alb.id
  target_id        = each.value["id"]
}

resource "aws_lb" "app_alb" {
  desync_mitigation_mode     = "defensive"
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "true"
  enable_http2               = "true"
  enable_waf_fail_open       = "false"
  idle_timeout               = "60"
  internal                   = "true"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "DIGIQAL-${var.environment}-INTERNAL"
  security_groups            = [data.aws_security_group.internal_alb.id]

  subnet_mapping {
    subnet_id = data.aws_subnet.subnet["${lower(var.environment)}-int-alb-subnet-a"].id
  }

  subnet_mapping {
    subnet_id = data.aws_subnet.subnet["${lower(var.environment)}-int-alb-subnet-b"].id
  }

  tags = {
    Name = "DIGIQAL-${var.environment}-INTERNAL-ALB"
  }

  tags_all = {
    Name = "DIGIQAL-${var.environment}-INTERNAL-ALB"
  }

  access_logs {
    bucket = "digiqal-alb-${lower(var.environment)}-int-log"
    enabled = "true"
  }
}

resource "aws_lb" "web_alb" {
  desync_mitigation_mode     = "defensive"
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "true"
  enable_http2               = "false"
  enable_waf_fail_open       = "false"
  idle_timeout               = "60"
  internal                   = "false"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "DIGIQAL-${var.environment}"
  security_groups            = [data.aws_security_group.external_alb.id]

  subnet_mapping {
    subnet_id = data.aws_subnet.subnet["${lower(var.environment)}-ext-alb-subnet-a"].id
  }

  subnet_mapping {
    subnet_id = data.aws_subnet.subnet["${lower(var.environment)}-ext-alb-subnet-b"].id
  }

  tags = {
    Name = "DIGIQAL-${var.environment}-ALB"
  }

  tags_all = {
    Name = "DIGIQAL-${var.environment}-ALB"
  }

  access_logs {
    bucket = "digiqal-alb-${lower(var.environment)}-log"
    enabled = "true"
  }
}

resource "aws_lb_listener" "app_alb" {
  certificate_arn = "arn:aws:acm:ap-east-1:761273030917:certificate/3114b50b-801f-43bb-a388-9cc1176a8dd5"

  default_action {
    target_group_arn = aws_lb_target_group.app_alb.id
    type             = "forward"
  }

  load_balancer_arn = aws_lb.app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

resource "aws_lb_listener" "web_alb" {
  certificate_arn = data.aws_acm_certificate.app_public.id

  default_action {
    target_group_arn = aws_lb_target_group.web_alb.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}
