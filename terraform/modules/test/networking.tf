data "aws_availability_zones" "available" {}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "eks-terraform-example",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "example" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.example.id}"

  tags = "${
    map(
     "Name", "eks-terraform-example",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "example" {
  vpc_id = "${aws_vpc.example.id}"

  tags {
    Name = "eks-terraform-example"
  }
}

resource "aws_route_table" "example" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.example.id}"
  }
}

resource "aws_route_table_association" "example" {
  count = 2

  subnet_id      = "${aws_subnet.example.*.id[count.index]}"
  route_table_id = "${aws_route_table.example.id}"
}

resource "aws_eip" "example" {
  count = 2
  vpc   = true
}

resource "aws_nat_gateway" "example" {
  count = 2

  allocation_id = "${aws_eip.example.*.id[count.index]}"
  subnet_id     = "${aws_subnet.example.*.id[count.index]}"

  tags = {
    Name = "kubernetes.io/role/internal-elb"
  }
}
