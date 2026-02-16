resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = merge(var.common_tags, { Name = var.project_name })
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnets" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(var.common_tags, { Name = "subnet-${count.index}" })
}

resource "aws_instance" "app" {
  count         = 2
  ami           = "ami-007fae589fdf6e955"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnets[count.index].id

  tags = merge(var.common_tags, { Name = var.instance_names[count.index] })
}

resource "aws_ebs_volume" "extra_disk" {
  count             = 4 # 2 instances * 2 disques
  availability_zone = aws_instance.app[floor(count.index / 2)].availability_zone
  size              = 8
  type              = var.disk_type
  tags              = var.common_tags
}

resource "aws_volume_attachment" "ebs_att" {
  count       = 4
  device_name = count.index % 2 == 0 ? "/dev/sdh" : "/dev/sdi"
  volume_id   = aws_ebs_volume.extra_disk[count.index].id
  instance_id = aws_instance.app[floor(count.index / 2)].id
}

resource "aws_s3_bucket" "docs" {
  bucket = "${var.project_name}-documentation-storage-2024"
  tags   = var.common_tags
}