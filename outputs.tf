output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_app_subnets" {
  value = module.vpc.private_app_subnets
}

output "private_db_subnets" {
  value = module.vpc.private_db_subnets
}

output "public_subnets_by_az" {
  value = module.vpc.public_subnets_by_az
}

output "private_app_subnets_by_az" {
  value = module.vpc.private_app_subnets_by_az
}

output "private_db_subnets_by_az" {
  value = module.vpc.private_db_subnets_by_az
}