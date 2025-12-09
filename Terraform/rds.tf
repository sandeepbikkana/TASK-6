resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1b"
}

resource "aws_db_subnet_group" "rds_subnets" {
  name = "${var.project}-rds-subnets"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.project}-db"
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "15.15"
  instance_class    = "db.t3.micro"

  db_name  = "strapi"
  username = var.db_username
  password = var.db_password

  publicly_accessible = false
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}
