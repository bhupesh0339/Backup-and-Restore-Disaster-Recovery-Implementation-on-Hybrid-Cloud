output "instance_id" {
  value = aws_instance.Instance1.id
}
output "eip-id" {
  value = aws_eip.eip.id
}
output "eip-ip" {
  value = aws_eip.eip.public_ip
}
output "instance_public_ip" {
  value = aws_instance.Instance1.public_ip
}