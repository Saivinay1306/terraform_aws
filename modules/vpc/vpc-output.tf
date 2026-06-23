
output "vpc_id" {
 value       = aws_vpc.terravpc.id
 description = "AWS VPC ID"
 sensitive   = false
 depends_on=[
  aws_vpc.terravpc
  ]
}

output "vpc_arn" {
  value = aws_vpc.terravpc.arn
  depends_on = [ aws_vpc.terravpc ]
  
}
output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.terracw_log_group.arn
  depends_on = [ aws_cloudwatch_log_group.terracw_log_group ]
  
}
output "flow_log_id" {
  value = aws_flow_log.terravpc_flowlog.id
  depends_on = [ aws_flow_log.terravpc_flowlog ]
} 
