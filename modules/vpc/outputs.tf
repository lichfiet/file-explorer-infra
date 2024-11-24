##
## Outputs
##

output "vpc_ids" {
  value = {
    vpc = {
      id = aws_vpc.vpc.id,

      cidr_block = aws_vpc.vpc.cidr_block,

      subnets = {
        public1  = {
          id = aws_subnet.public_subnet_1.id,
          cidr_block = aws_subnet.public_subnet_1.cidr_block

          route_table = {
            id = aws_route_table.public_subnet_1_route_table.id
          }
        },
        public2  = {
          id = aws_subnet.public_subnet_1.id,
          cidr_block = aws_subnet.public_subnet_1.cidr_block

          route_table = {
            id = aws_route_table.public_subnet_1_route_table.id
          }
        },
        private = {
          id = length(aws_route_table.private_route_table) > 0 ? aws_route_table.private_route_table[0].id : false
          cidr_block = aws_subnet.private_subnet.cidr_block

          route_table = {
            id = length(aws_route_table.private_route_table) > 0 ? aws_route_table.private_route_table[0].id : false
          }
        } 
      },
      security_groups = {
        public = {
          id = aws_security_group.public_subnet_sg.id
        }
      }
    },
  
    nat_gateway = {
      id = length(aws_nat_gateway.nat_gateway) > 0 ? aws_nat_gateway.nat_gateway[0].id : false
    },

    internet_gateway = {
      id = aws_internet_gateway.internet_gateway.id
    }
  }
}