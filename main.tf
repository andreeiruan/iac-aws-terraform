module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
}

module "alb" {
  source                     = "./modules/alb"
  cluster_name               = var.cluster_name
  vpc_id                     = module.vpc.vpc_id
  public_subnets             = [module.vpc.subnet_public_one_id, module.vpc.subnet_public_two_id]
  domain_name_certifate      = "*.test-codox.dev.ezops.com.br"
  hosted_zone_domain         = "dev.ezops.com.br"
  security_group_internal_id = module.vpc.sg_allow_internal_access_id
  blue_port                  = var.blue_port
  green_port                 = var.green_port
  use_https                  = var.use_https
  subdomain                  = "nginx-test.test-codox"
}

# module "newtwork_lb" {
#   source          = "../modules/network_elb"
#   cluster_name    = var.cluster_name
#   vpc_id          = module.vpc.vpc_id
#   private_subnets = [module.vpc.subnet_private_one_id, module.vpc.subnet_private_two_id]
# }

# module "sqs_queue" {
#   source               = "../modules/SQS"
#   queue_name           = "${var.cluster_name}_queue"
#   is_dead_letter_queue = true
# }

# module "redis" {
#   source             = "../modules/elastic_cache"
#   cluster_name       = var.cluster_name
#   private_subnets    = [module.vpc.subnet_private_one_id, module.vpc.subnet_private_two_id]
#   replica_nodes      = 1
#   security_group_ids = [module.vpc.sg_allow_internal_access_id]
# }

module "service" {
  source                  = "./modules/service"
  cluster_name            = var.cluster_name
  keypair_name            = "beta-treinamentos"
  ecs_image_id            = "ami-022ed07b73d6b46b2"
  security_group_internal = module.vpc.sg_allow_internal_access_id
  instance_type           = "t3a.medium"
  asg_min_instances       = 1
  asg_desired_instances   = 1
  asg_max_instances       = 3
  target_blue_arn         = module.alb.target_blue_arn
  private_subnets         = [module.vpc.subnet_private_one_id, module.vpc.subnet_private_two_id]
  public_subnet           = module.vpc.subnet_public_one_id
  vpc_id                  = module.vpc.vpc_id
  service_name            = "smd"
  cpu_task                = 256
  memory_task             = 512
  cpu_container           = 75
  memory_container        = 256
  blue_port               = var.blue_port
  green_port              = var.green_port
  ecs_node_volume_size    = 30
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.cluster_name}-bucket-pipeline"

  provisioner "local-exec" {
    command = "/bin/sh -c ./scripts/put-file.sh"

    on_failure = fail

    environment = {
      REPO_NAME          = module.service.codecommit_repository_name
      EXEC_TASK_ROLE_ARN = module.service.exec_task_role_arn
      CONTAINER_NAME     = module.service.container_name
      TASK_FAMILY        = module.service.task_family
    }
  }

  provisioner "local-exec" {
    command = "/bin/sh -c ./scripts/push-docker-local-image.sh"

    on_failure = fail

    environment = {
      AWS_REGION         = data.aws_region.current.name      
      IMAGE_LOCAL        = "${var.docker_image_local}:${var.docker_image_tag}"
      ECR_REPOSITORY_URI = module.service.ecr_repository_uri
      ECR_REGISTRY_ID    = module.service.ecr_registry_id
    }
  }
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

module "code_deploy" {
  source = "./modules/code_deploy"
  depends_on = [
    module.service,
    aws_s3_bucket.codepipeline_bucket
  ]
  cluster_name               = var.cluster_name
  service_name               = "smd"
  canary_interval            = 10
  canary_percentage          = 50
  canary_cleanup_timeout     = 10
  target_blue_arn            = module.alb.target_blue_arn
  target_green_arn           = module.alb.target_green_arn
  blue_listener_http_arn     = module.alb.blue_listener_protocol_arn
  blue_listener_https_arn    = module.alb.blue_listener_https_arn
  green_listener_http_arn    = module.alb.green_listener_http_arn
  ecr_repository_name        = module.service.ecr_repository_name
  use_https                  = var.use_https
  codecommit_repository_name = module.service.codecommit_repository_name
  pipeline_bucket_name       = aws_s3_bucket.codepipeline_bucket.id
}


