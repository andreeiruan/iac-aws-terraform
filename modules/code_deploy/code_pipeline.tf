resource "aws_codepipeline" "codepipeline" {
  depends_on = [
    aws_s3_bucket.codepipeline_bucket,
    aws_iam_role.pipeline,
    aws_codedeploy_app.app,
    aws_codedeploy_deployment_group.deploy_group    
  ]

  name     = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-cp"
  role_arn = aws_iam_role.pipeline.arn  

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name      = "Artifacts"
      category  = "Source"
      owner     = "AWS"
      provider  = "CodeCommit"
      version   = "1"
      region    = data.aws_region.current.name
      run_order = 1
      namespace = "SourceVariables"

      configuration = {
        RepositoryName       = var.codecommit_repository_name
        BranchName           = "master"
        OutputArtifactFormat = "CODE_ZIP"
        PollForSourceChanges = false
      }

      output_artifacts = ["SourceArtifact"]
    }

    action {
      name      = "Image"
      category  = "Source"
      owner     = "AWS"
      provider  = "ECR"
      version   = "1"
      region    = data.aws_region.current.name
      run_order = 1

      configuration = {
        ImageTag       = "latest"
        RepositoryName = var.ecr_repository_name
      }

      output_artifacts = ["Image"]
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      region          = data.aws_region.current.name
      run_order       = 1
      namespace       = "DeployVariables"
      input_artifacts = ["SourceArtifact", "Image"]


      configuration = {
        AppSpecTemplateArtifact        = "SourceArtifact"
        AppSpecTemplatePath            = "appspec.yaml"
        ApplicationName                = aws_codedeploy_app.app.name
        DeploymentGroupName            = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-deploy-group"
        Image1ArtifactName             = "Image"
        Image1ContainerName            = "IMAGE_TO_SET"
        TaskDefinitionTemplateArtifact = "SourceArtifact"
        TaskDefinitionTemplatePath     = "taskdef.json"
      }
    }
  }
}


resource "aws_cloudwatch_event_rule" "CWE_event_rule" {
  name        = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-pipeline-event-rule"
  description = "Triggers pipeline on ecr image push"
  is_enabled  = true
  role_arn    = aws_iam_role.CWE.arn


  event_pattern = <<EOF
{
  "source": [
    "aws.ecr"
  ],
  "detail": {
    "action-type": [
      "PUSH"
    ],
    "image-tag": [
      "latest"
    ],
    "repository-name": ["${var.ecr_repository_name}"],
    "result": [
      "SUCCESS"
    ]
  },
  "detail-type": [
    "ECR Image Action"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "target" {
  target_id = "1"
  rule      = aws_cloudwatch_event_rule.CWE_event_rule.name
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.CWE.arn
}
