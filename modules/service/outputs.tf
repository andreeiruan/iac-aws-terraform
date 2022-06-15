output "codecommit_repository_name" {
  value = aws_codecommit_repository.artifact_store.repository_name
}

output "exec_task_role_arn" {
  value = aws_iam_role.ecs_role.arn
}

output "container_name" {
  value = "${var.service_name}_container"
}

output "task_family" {
  value = aws_ecs_task_definition.task.family
}

output "ecr_repository_name" {
  value = aws_ecr_repository.repository.name
}

output "ecr_repository_uri" {
  value = aws_ecr_repository.repository.repository_url
}

output "ecr_registry_id" {
  value = aws_ecr_repository.repository.registry_id
}