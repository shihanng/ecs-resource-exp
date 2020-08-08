module "ecs" {
  source = "./modules/simple_ecs"

  project_name = "ecs-memory-exp"
  environment  = terraform.workspace
}
