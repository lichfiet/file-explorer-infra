##
## Outputs
##

output "vpc_ids" {
  value = {
    vpc = aws_vpc.vpc.id,
    subnets = {
      public  = aws_subnet.public_subnet.id,
      private = aws_subnet.private_subnet.id
    },
    route_tables = {
      public  = aws_route_table.public_route_table.id,
      private = aws_route_table.private_route_table.id
    },
    nat_gateway = aws_nat_gateway.nat_gateway.id,
    internet_gateway = aws_internet_gateway.internet-gateway.id
  }
}