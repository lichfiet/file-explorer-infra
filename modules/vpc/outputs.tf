##
## Outputs
##

output "vpc_ids" {
  value = {
    vpc = {
      id = aws_vpc.vpc.id,

      cidr_block = aws_vpc.vpc.cidr_block,

      subnets = {
        public  = {
          id = aws_subnet.public_subnet.id,
          cidr_block = aws_subnet.public_subnet.cidr_block

          route_table = {
            id = aws_route_table.public_route_table.id
            association = aws_route_table_association.learning_route_table_association.id
          }
        },
        private = {
          id = length(aws_route_table.private_route_table) > 0 ? aws_route_table.private_route_table[0].id : false
          cidr_block = aws_subnet.private_subnet.cidr_block

          route_table = {
            id = length(aws_route_table.private_route_table) > 0 ? aws_route_table.private_route_table[0].id : false
            association = length(aws_route_table_association.private_route_table_association) > 0 ? aws_route_table_association.private_route_table_association[0].id : false
          }
        } 
      },
    },
  
    nat_gateway = {
      id = length(aws_nat_gateway.nat_gateway) > 0 ? aws_nat_gateway.nat_gateway[0].id : false
    },

    internet_gateway = {
      id = aws_internet_gateway.internet-gateway.id
    }
  }
}