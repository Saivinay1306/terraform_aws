
output "vpc_id" {
 value       = aws_vpc.terravpc.id
 description = "AWS VPC ID"
 sensitive   = false
 depends_on=[
  aws_vpc.terravpc
  ]
}