resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.service_name}-execution-role"

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
  name = "${var.service_name}-cwe-role"

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
    name = "${var.service_name}-cwe-exec-policy"

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
}

resource "aws_iam_role_policy" "pipeline" {
  role = aws_iam_role.pipeline.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
  {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "codecommit:UploadArchive",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:GetCommit",
                "codecommit:GetBranch",
                "codecommit:CancelUploadArchive",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuilds",
                "codestar-connections:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "${data.aws_s3_bucket.codepipeline_bucket.arn}/*"
        }
  ]
}
POLICY
}
