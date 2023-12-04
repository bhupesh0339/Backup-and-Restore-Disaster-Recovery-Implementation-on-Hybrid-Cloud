resource "aws_instance" "Instance1" {
  ami                    = data.aws_ami.backend_ami.id
  instance_type          = var.instance-type
  key_name               = var.key_pair_name
  vpc_security_group_ids = var.vpc_security_group_ids
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = var.private_key_file
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update"
    ]
  }  
  tags = {
    Name = var.InstanceNameTag
  }
}
data "aws_ami" "backend_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}