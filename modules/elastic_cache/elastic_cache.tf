resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "i-${var.env}-${var.infra_version}-sg"
  subnet_ids = var.private_subnets
}

resource "aws_elasticache_replication_group" "cluster" {
  automatic_failover_enabled = true
  auto_minor_version_upgrade = true
  node_type                  = "cache.m4.large"
  replication_group_id       = "i-${var.env}-${var.infra_version}-redis"
  subnet_group_name          = aws_elasticache_subnet_group.subnet_group.name
  engine                     = "redis"
  engine_version             = "5.0.6"
  replicas_per_node_group    = var.replica_nodes
  num_node_groups            = 1
  description                = "i-${var.env}-${var.infra_version}-redis"
  parameter_group_name       = "default.redis5.0"
  security_group_ids         = var.security_group_ids
  port                       = 6379
}
