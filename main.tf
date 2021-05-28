provider "aws" {
  region = local.region
}

locals {
  name     = "gitea-postgresql"
  region   = "eu-west-2"
  identity = "gitea-test"
  tags = {
    Owner       = "NickB"
    Environment = "dev"
  }
}

resource "aws_db_instance" "gitea-test" {
  name              = "gitea"
  allocated_storage = 20
  # db_subnet_group_name = aws_default_vpc.default_vpc.id
  engine                 = "postgres"
  engine_version         = "12.5"
  identifier             = local.identity
  snapshot_identifier    = var.snapshot
  instance_class         = "db.t2.micro"
  skip_final_snapshot    = true
  storage_encrypted      = false
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
}

resource "aws_default_vpc" "default_vpc" {
}


resource "aws_security_group" "db_security_group" {
  name        = local.name
  description = "Gitea PostgreSQL security group"
  vpc_id      = aws_default_vpc.default_vpc.id

  # ingress
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "PostgreSQL access from within VPC"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}