resource "aws_instance" "bastion" {
  ami                  = local.ami_id
  instance_type        = "t3.micro" # Cost-effective instance type
  subnet_id            = local.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids = [local.bastion_sg_id]

  user_data = templatefile("${path.module}/bastion.sh.tfpl", {
    partition_number = 4
    extend_size = 30
  })
   root_block_device {
    volume_size           = 50         # Size in GiB
    volume_type           = "gp3"      # General Purpose SSD (gp2, gp3, io1, io2, etc.)
    
    tags = merge(
       local.common_tags,
       {
        Name = "${local.common_name}-bastion"
       }
    )
  }
  tags = merge(
    var.bastion_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-bastion"
    }
  )
}
