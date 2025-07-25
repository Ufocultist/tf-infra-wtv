provider "aws" {
  alias  = "us_e1"
  region = "us-east-1"
}

module "vpc" {
  source               = "../modules/vpc"
  env                  = var.env
  cidr_block           = var.cidr_block
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  providers = {
    aws = aws.us_e1
  }
}

module "nat_gateway" {
  source             = "../modules/nat_gw"
  env                = var.env
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  igw_id             = module.vpc.igw_id
  providers = {
    aws = aws.us_e1
  }
}

module "secret" {
  source           = "../modules/awssm"
  env              = var.env
  db_username      = var.db_username
  db_password      = var.db_password
  db_root_password = var.db_root_password
  db_host          = var.db_host
  db_port          = var.db_port
  db_name          = var.db_name
  flask_secret     = var.flask_secret
}

module "ecr" {
  source       = "../modules/ecr"
  name         = var.app_name
  scan_on_push = var.scan_on_push
  force_delete = var.force_delete
  tags = {
    Environment = var.env
    App         = var.name
  }
}

module "iam_eks_cluster" {
  source         = "../modules/iam"
  name           = var.name
  env            = var.env
  aws_account_id = var.aws_account_id
  repo_name      = var.repo_name
  region         = var.region
}

module "eks" {
  source                  = "../modules/eks"
  name                    = var.name
  env                     = var.env
  region                  = var.region
  aws_account_id          = var.aws_account_id
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  eks_role_arn            = module.iam_eks_cluster.eks_role_arn
  eks_node_group_role_arn = module.iam_eks_cluster.eks_node_group_role_arn
  capacity_type           = var.capacity_type
  instance_types          = var.instance_types
  ami_type                = var.ami_type
  k8s_version             = var.k8s_version
}