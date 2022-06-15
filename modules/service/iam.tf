data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name                = "${var.cluster_name}__EC2_Role"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.ec2_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_role" "ecs_role" {
  name                = "${var.cluster_name}__ECS_Role"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.ecs_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"]
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.cluster_name}_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.cluster_name}_ecs_instance_profile"
  role = aws_iam_role.ecs_role.name
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.service_name}-execution-role-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "ECSTaskExecutionRolePolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ecr:*", "logs:CreateLogStream", "logs:PutLogEvents", "ssm:GetParameters", "secretsmanager:GetSecretValue", "kms:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

