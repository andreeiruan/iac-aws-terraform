resource "aws_iam_role" "ecs_execution_role" {
  name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"]
}

resource "aws_iam_role" "code_deploy_role" {
  name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-code-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"]
}

resource "aws_iam_role" "CWE" {
  name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-cwe-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-cwe-exec-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["codepipeline:StartPipelineExecution"]
          Effect   = "Allow"
          Resource = "${aws_codepipeline.codepipeline.arn}"
        },
      ]
    })
  }
}

resource "aws_iam_role" "pipeline" {
  path = "/service-role/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }      
    ]
}
  EOF


  inline_policy {
    name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-cp-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["s3:*"]
          Effect   = "Allow"
          Resource = "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        }
      ]
    })
  }
}

# resource "aws_iam_role_policy" "pipeline" {
#   role = aws_iam_role.pipeline.name

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#   {
#             "Sid": "",
#             "Effect": "Allow",
#             "Action": [
#                 "*"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Action": [
#                 "s3:*"
#             ],
#             "Resource": "${aws_s3_bucket.codepipeline_bucket.arn}/*"
#         }
#   ]
# }
# POLICY
# }


