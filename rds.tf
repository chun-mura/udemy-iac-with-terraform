# ------------------------
# RDS parameter group
# ------------------------
resource "aws_db_parameter_group" "mysql_standalone_parameter_group" {
  name        = "${var.project}-${var.environment}-mysql-standalone-parameter-group"
  family      = "mysql8.0"
  description = "mysql standalone parameter group"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# ------------------------
# RDS option group
# ------------------------
resource "aws_db_option_group" "mysql_standalone_option_group" {
  name                 = "${var.project}-${var.environment}-mysql-standalone-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

# ------------------------
# RDS subnet group
# ------------------------
resource "aws_db_subnet_group" "mysql_standalone_subnet_group" {
  name       = "${var.project}-${var.environment}-mysql-standalone-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1c.id]

  tags = {
    Name        = "${var.project}-${var.environment}-mysql-standalone-subnet-group"
    Project     = var.project
    Environment = var.environment
  }
}

# ------------------------
# RDS instance
# ------------------------
resource "random_string" "db_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "mysql_standalone" {
  # engine
  engine         = "mysql"
  engine_version = "8.0"

  # identifier
  identifier = "${var.project}-${var.environment}-mysql-standalone"

  # credentials
  username = "admin"
  password = random_string.db_password.result

  # instance
  instance_class = "db.t2.micro"

  # storage
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp2"
  storage_encrypted     = true

  # network
  multi_az               = false
  availability_zone      = "ap-northeast-1a"
  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  port                   = 3306

  # database
  name                 = "tastylog"
  parameter_group_name = aws_db_parameter_group.mysql_standalone_parameter_group.name
  option_group_name    = aws_db_option_group.mysql_standalone_option_group.name

  # backup
  backup_window              = "04:00-05:00"
  backup_retention_period    = 7
  maintenance_window         = "Mon:05:00-Mon:08:00"
  auto_minor_version_upgrade = false

  # delete protection
  deletion_protection = false
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name        = "${var.project}-${var.environment}-mysql-standalone"
    Project     = var.project
    Environment = var.environment
  }
}
