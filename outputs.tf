output "instance_id" {
    description = "ID of the EC2 instance"
    value       = aws_instance.testme01.id 
}

output "instance_public_ip" {
    description = "Public IP of the EC2 instance for SSH access"
    value       = aws_instance.testme01.public_ip 
}