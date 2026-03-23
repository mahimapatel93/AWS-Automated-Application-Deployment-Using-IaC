resource "aws_instance" "servers" {

  count = var.no_of_ec2

  ami = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type

  tags = {
    Name = "Terraform-Server-${count.index}"
  }

}