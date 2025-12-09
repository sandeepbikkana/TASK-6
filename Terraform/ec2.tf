resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "strapi" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y docker.io awscli -y
systemctl enable docker
systemctl start docker

# Login to ECR
aws ecr get-login-password --region ap-south-1 \
 | docker login --username AWS --password-stdin 730335385079.dkr.ecr.ap-south-1.amazonaws.com/strapi-app

# Pull Image
docker pull 730335385079.dkr.ecr.ap-south-1.amazonaws.com/strapi-app:latest

# Run Container
docker run -d --name strapi \
  -p 80:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST={rds_endpoint} \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=strapi \
  -e DATABASE_USERNAME=postgres \
  -e DATABASE_PASSWORD=postgres \
  -e DATABASE_SSL_ENABLED=true \
  -e DATABASE_SSL_REJECT_UNAUTHORIZED=false \
730335385079.dkr.ecr.ap-south-1.amazonaws.com/strapi-app:latest
EOF

  tags = {
    Name = "${var.project}-ec2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.strapi.public_ip
}
