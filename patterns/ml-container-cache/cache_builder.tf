module "ebs_snapshot_builder" {
  source  = "clowdhaus/ebs-snapshot-builder/aws"
  version = "~> 2.0"

  name = local.name

  # Images to cache
  public_images = [
    "nvcr.io/nvidia/k8s-device-plugin:v0.17.4", # 120 MB compressed / 351 MB decompressed
    "nvcr.io/nvidia/pytorch:25.08-py3",         # 9.5 GB compressed / 20.4 GB decompressed
  ]

  # AZs where EBS fast snapshot restore will be enabled
  fsr_availability_zone_names = local.azs

  vpc_id    = module.vpc.vpc_id
  subnet_id = element(module.vpc.private_subnets, 0)

  tags = local.tags
}
