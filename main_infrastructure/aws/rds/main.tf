resource "aws_db_instance" "default" {
  allocated_storage      = var.storage_size
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  username               = var.db_username
  password               = var.Password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  publicly_accessible    = var.publicly_exposed
  vpc_security_group_ids = var.security_group_ids
}

