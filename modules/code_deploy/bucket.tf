resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-bucket-pipeline"

  provisioner "local-exec" {
    command = "/bin/sh -c ./scripts/put-file.sh"

    environment = {
      REPO_NAME          = var.codecommit_repository_name
      EXEC_TASK_ROLE_ARN = var.exec_task_role_arn
      CONTAINER_NAME     = var.container_name
      TASK_FAMILY        = var.task_family
      AWS_REGION         = data.aws_region.current.name
    }
  }

  provisioner "local-exec" {
    command = "/bin/sh -c ./scripts/empty-bucket.sh"
    when    = "destroy"


    environment = {
      BUCKET_NAME = self.id
    }
  }
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}
