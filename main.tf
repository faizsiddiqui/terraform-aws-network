resource "aws_vpc" "vpc" {
  cidr_block                       = var.aws_vpc_cidr
  instance_tenancy                 = "default"
  enable_dns_hostnames             = false
  enable_dns_support               = false
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = var.aws_vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.aws_vpc_name}-igw"
  }
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.aws_vpc_name}-eigw"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_subnet" "subnet-public" {
  count             = length(var.aws_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 4, count.index)
  availability_zone = "${var.aws_region}${element(var.aws_zones, count.index)}"
  tags = {
    Name = "${var.aws_vpc_name}-public-${element(var.aws_zones, count.index)}"
  }
}

resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.aws_vpc_name}-rt-public"
  }
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rt-assoc-public" {
  count          = length(var.aws_zones)
  subnet_id      = element(aws_subnet.subnet-public.*.id, count.index)
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_subnet" "subnet-private" {
  count             = length(var.aws_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 4, count.index + 8)
  availability_zone = "${var.aws_region}${element(var.aws_zones, count.index)}"
  tags = {
    Name = "${var.aws_vpc_name}-private-${element(var.aws_zones, count.index)}"
  }
}

resource "aws_route_table" "rt-private" {
  count  = length(var.aws_zones)
  vpc_id = aws_vpc.vpc.id
  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.eigw.id
  }
  tags = {
    Name = "${var.aws_vpc_name}-rt-private-${element(var.aws_zones, count.index)}"
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = length(var.aws_zones)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = element(aws_route_table.rt-private.*.id, count.index)
}

resource "aws_route_table_association" "rt-assoc-private" {
  count          = length(var.aws_zones)
  subnet_id      = element(aws_subnet.subnet-private.*.id, count.index)
  route_table_id = element(aws_route_table.rt-private.*.id, count.index)
}
