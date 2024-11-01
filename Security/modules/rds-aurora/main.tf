resource "aws_rds_cluster" "cluster" {
  engine                  = "aurora-mysql"
  engine_mode             = "provisioned"
  engine_version          = "5.7.mysql_aurora.2.11.1"
  cluster_identifier      = var.project_name
  master_username         = "foo"
  master_password         = "709Gip_r0se"
  storage_encrypted       = true
  vpc_security_group_ids  = [var.security_group_ids]
  
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  
  backup_retention_period = 1
  skip_final_snapshot     = true
  tags                    = var.tags
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier         = "${var.project_name}-${count.index}"
  count              = 1
  cluster_identifier = aws_rds_cluster.cluster.id
  instance_class     = "db.t3.small"
  engine             = aws_rds_cluster.cluster.engine
  engine_version     = aws_rds_cluster.cluster.engine_version
  
  publicly_accessible = false
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids
}