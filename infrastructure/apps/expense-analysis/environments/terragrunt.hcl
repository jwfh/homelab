locals {
  # Find backend.hcl in the environment directory (parent of module directories)
  backend = read_terragrunt_config(find_in_parent_folders("backend.hcl"))
  
  # Get the relative path from the environment dir to create unique state keys
  # e.g., namespace, ingress, storage, database, application
  relative_path = basename(get_terragrunt_dir())
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
terraform {
  required_version = ">= 1.10.6"

  backend "s3" {
    profile      = "${local.backend.inputs.profile_name}"
    bucket       = "${local.backend.inputs.terraform_bucket}"
    key          = "expense-analysis/${local.backend.inputs.environment}/${local.relative_path}/terraform.tfstate"
    region       = "${local.backend.inputs.aws_region}"
    encrypt      = true
    use_lockfile = true
  }
}
EOF
}

generate "provider" {
  path      = "generated-providers.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
provider "aws" {
  region  = "${local.backend.inputs.aws_region}"
  profile = "${local.backend.inputs.profile_name}"
}

provider "kubernetes" {
  config_path = "${local.backend.inputs.kube_config_path}"
}

provider "helm" {
  kubernetes {
    config_path = "${local.backend.inputs.kube_config_path}"
  }
}
EOF
}

generate "versions" {
  path      = "generated-versions.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
EOF
}
