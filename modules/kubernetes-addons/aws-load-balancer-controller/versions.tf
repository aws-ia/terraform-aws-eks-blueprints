terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    merge = {
      source  = "LukeCarrier/merge"
      version = ">= 0.1.1"
    }
  }
}
