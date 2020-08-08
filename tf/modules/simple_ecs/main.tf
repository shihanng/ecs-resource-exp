locals {
  project_name = var.project_name
  environment  = var.environment
  common_name  = "${local.project_name}-${local.environment}"
  tags = {
    Name        = local.project_name
    Environment = local.environment
  }
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 2.0"

  create_ecs = true
  name       = local.common_name
  tags       = local.tags
}

data "aws_ami" "ecs-optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*.*.*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # AWS
}

resource "aws_iam_role" "ecs_instance" {
  name = "${local.common_name}-ecs-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.tags
}

data "aws_iam_policy" "ecs_ec2" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = data.aws_iam_policy.ecs_ec2.arn
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = local.common_name
  role = aws_iam_role.ecs_instance.name
}

resource "aws_instance" "ecs_instance" {
  count         = 1
  ami           = data.aws_ami.ecs-optimized.id
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ecs_instance.name

  tags = local.tags

  user_data = <<EOF
              #!/bin/bash
              echo ECS_CLUSTER=${module.ecs.this_ecs_cluster_name} >> /etc/ecs/ecs.config
              EOF
}
