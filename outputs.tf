output "instance_id" {
    description = "ID of the EC2 instance"
    value       = aws_instance.basic_ec2_instance.id 
}

output "instance_public_ip" {
    description = "Public IP of the EC2 instance for SSH access"
    value       = aws_instance.basic_ec2_instance.public_ip 
}