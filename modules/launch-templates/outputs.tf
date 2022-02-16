output "launch_template_id" {
  description = "Launch Template IDs"
  value       = { for template in sort(keys(var.launch_template_config)) : template => aws_launch_template.this[template].id }
}

output "launch_template_image_id" {
  description = "Launch Template Image IDs"
  value       = { for template in sort(keys(var.launch_template_config)) : template => aws_launch_template.this[template].image_id }
}

output "launch_template_arn" {
  description = "Launch Template ARNs"
  value       = { for template in sort(keys(var.launch_template_config)) : template => aws_launch_template.this[template].arn }
}

output "launch_template_name" {
  description = "Launch Template Names"
  value       = { for template in sort(keys(var.launch_template_config)) : template => aws_launch_template.this[template].name }
}

output "launch_template_default_version" {
  description = "Launch Template Default Versions"
  value       = { for template in sort(keys(var.launch_template_config)) : template => aws_launch_template.this[template].default_version }
}

output "launch_template_latest_version" {
  description = "Launch Template Latest Versions"
  value       = { for template in sort(keys(var.launch_template_config)) : template => aws_launch_template.this[template].latest_version }
}
