#############################################
# RANDOM SUFFIX FOR UNIQUE RESOURCE CREATION
#############################################

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

#############################################
# DEFAULT VPC & SUBNET DISCOVERY
#############################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_caller_identity" "current" {}

#############################################
# ECR REPOSITORY
#############################################

resource "aws_ecr_repository" "strapi" {
  name = "${var.docker_repo}-${random_string.suffix.result}"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#############################################
# SECURITY GROUP FOR EC2
#############################################

resource "aws_security_group" "ec2_sg" {
  name        = "sandeep-ec2-sg-${random_string.suffix.result}"
  description = "Allow SSH + Strapi"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow Strapi"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#############################################
# SECURITY GROUP FOR RDS
#############################################

resource "aws_security_group" "rds_sg" {
  name        = "sandeep-rds-sg-${random_string.suffix.result}"
  description = "Allow EC2 Postgres"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Allow Postgres from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#############################################
# DB SUBNET GROUP
#############################################

resource "aws_db_subnet_group" "default" {
  name       = "sandeep-db-subnet-group-${random_string.suffix.result}"
  subnet_ids = data.aws_subnets.default.ids
}

#############################################
# RDS POSTGRES INSTANCE
#############################################

resource "aws_db_instance" "postgres" {
  identifier              = "sandeep-postgres-${random_string.suffix.result}"
  engine                  = "postgres"
  engine_version          = "15.15"
  instance_class          = "db.t3.micro"

  username            = var.db_username
  password            = var.db_password
  allocated_storage   = 20
  skip_final_snapshot = true

  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
}

#############################################
# EC2 INSTANCE (Ubuntu)
#############################################

resource "aws_instance" "ubuntu" {
  ami                         = "ami-0f5ee92e2d63afc18" # Ubuntu 22.04 LTS (ap-south-1)
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name

  user_data = <<-EOF
#!/bin/bash

apt update -y
apt install -y docker.io awscli
systemctl enable docker
systemctl start docker

ACCOUNT_ID=${data.aws_caller_identity.current.account_id}
REGION=${var.aws_region}
ECR_REPO="${var.ACCOUNT_ID}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.docker_repo}-${random_string.suffix.result}"
IMAGE="$ECR_REPO:${var.image_tag}"

# Login to ECR
aws ecr get-login-password --region $REGION | docker login \
    --username AWS --password-stdin ${var.ACCOUNT_ID}.dkr.ecr.${var.aws_region}.amazonaws.com

# Pull latest application image
docker pull $IMAGE

# Restart container if exists
docker stop strapi || true
docker rm strapi || true

# Run Strapi container
docker run -d --name strapi -p 1337:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=${aws_db_instance.postgres.address} \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=postgres \
  -e DATABASE_USERNAME=${var.db_username} \
  -e DATABASE_PASSWORD=${var.db_password} \
  $IMAGE

EOF

  tags = {
    Name = "sandeep-ec2-${random_string.suffix.result}"
  }
}

#############################################
# OUTPUTS
#############################################
output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "ecr_repo_url" {
  value = aws_ecr_repository.strapi.repository_url
}






