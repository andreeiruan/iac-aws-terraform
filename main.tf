module "vpc" {
  source        = "./modules/vpc"
  env           = var.env
  infra_version = var.infra_version
}

module "alb" {
  source                     = "./modules/alb"
  env                        = var.env
  infra_version              = var.infra_version
  major_version              = var.major_version
  service_name               = var.service_name
  vpc_id                     = module.vpc.vpc_id
  public_subnets             = [module.vpc.subnet_public_one_id, module.vpc.subnet_public_two_id]
  hosted_zone_domain         = "dev.ezops.com.br"
  security_group_internal_id = module.vpc.sg_allow_internal_access_id
  blue_port                  = var.blue_port
  green_port                 = var.green_port
  use_https                  = var.use_https
  subdomain                  = "nginx-test.test-codox"
}

module "sqs_queue" {
  source               = "./modules/SQS"
  is_dead_letter_queue = true
  env                  = var.env
  infra_version        = var.infra_version
}

module "redis" {
  source             = "./modules/elastic_cache"
  private_subnets    = [module.vpc.subnet_private_one_id, module.vpc.subnet_private_two_id]
  replica_nodes      = 1
  security_group_ids = [module.vpc.sg_allow_internal_access_id]
  env                = var.env
  infra_version      = var.infra_version
}

module "service" {
  source                  = "./modules/service"
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
  cpu_task                = 256
  memory_task             = 512
  cpu_container           = 75
  memory_container        = 256
  blue_port               = var.blue_port
  green_port              = var.green_port
  ecs_node_volume_size    = 30
  docker_image_local      = var.docker_image_local
  docker_image_tag        = var.docker_image_tag
  env                     = var.env
  infra_version           = var.infra_version
  major_version           = var.major_version
  service_name            = var.service_name
}

module "code_deploy" {
  source = "./modules/code_deploy"
  depends_on = [
    module.service
  ]
  env                        = var.env
  infra_version              = var.infra_version
  major_version              = var.major_version
  service_name               = var.service_name
  service_ecs_name           = module.service.service_ecs_name
  cluster_name               = module.service.cluster_name
  container_name             = module.service.container_name
  exec_task_role_arn         = module.service.exec_task_role_arn
  task_family                = module.service.task_family
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
}

# module "newtwork_lb" {
#   source          = "./modules/network_elb"
#   vpc_id          = module.vpc.vpc_id
#   private_subnets = [module.vpc.subnet_private_one_id, module.vpc.subnet_private_two_id]
#   env             = var.env
#   infra_version   = var.infra_version
#   major_version   = var.major_version
#   service_name    = "${var.service_name}-pv"
#   blue_port       = var.blue_port
#   green_port      = var.green_port
# }

module "alb_two" {
  source                     = "./modules/alb"
  env                        = var.env
  infra_version              = var.infra_version
  major_version              = var.major_version
  service_name               = var.service_name
  vpc_id                     = module.vpc.vpc_id
  public_subnets             = [module.vpc.subnet_public_one_id, module.vpc.subnet_public_two_id]
  hosted_zone_domain         = "dev.ezops.com.br"
  security_group_internal_id = module.vpc.sg_allow_internal_access_id
  blue_port                  = var.blue_port
  green_port                 = var.green_port
  use_https                  = var.use_https
  subdomain                  = "nginx-test.test-codox"
}

module "service_private" {
  source                  = "./modules/service"
  keypair_name            = "beta-treinamentos"
  ecs_image_id            = "ami-022ed07b73d6b46b2"
  security_group_internal = module.vpc.sg_allow_internal_access_id
  instance_type           = "t3a.medium"
  asg_min_instances       = 1
  asg_desired_instances   = 1
  asg_max_instances       = 3
  target_blue_arn         = module.alb_two.target_blue_arn
  private_subnets         = [module.vpc.subnet_private_one_id, module.vpc.subnet_private_two_id]
  public_subnet           = module.vpc.subnet_public_one_id
  vpc_id                  = module.vpc.vpc_id
  cpu_task                = 256
  memory_task             = 512
  cpu_container           = 75
  memory_container        = 256
  blue_port               = var.blue_port
  green_port              = var.green_port
  ecs_node_volume_size    = 30
  docker_image_local      = var.docker_image_local
  docker_image_tag        = var.docker_image_tag
  env                     = var.env
  infra_version           = var.infra_version
  major_version           = var.major_version
  service_name            = "${var.service_name}-two"
}

module "code_deploy_private" {
  source = "./modules/code_deploy"
  depends_on = [
    module.service_private
  ]
  env                        = var.env
  infra_version              = var.infra_version
  major_version              = var.major_version
  service_name               = "${var.service_name}-two"
  service_ecs_name           = module.service_private.service_ecs_name
  cluster_name               = module.service_private.cluster_name
  container_name             = module.service_private.container_name
  exec_task_role_arn         = module.service_private.exec_task_role_arn
  task_family                = module.service_private.task_family
  canary_interval            = 10
  canary_percentage          = 50
  canary_cleanup_timeout     = 10
  target_blue_arn            = module.alb_two.target_blue_arn
  target_green_arn           = module.alb_two.target_green_arn
  blue_listener_http_arn     = module.alb_two.blue_listener_protocol_arn
  # networw_lb                 = true
  green_listener_http_arn    = module.alb_two.green_listener_http_arn
  ecr_repository_name        = module.service_private.ecr_repository_name
  use_https                  = true
  codecommit_repository_name = module.service_private.codecommit_repository_name
}

