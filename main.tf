variable "security_group" {
  description = " A list of security groups to create"
  type = map(object({
    #name        = string we can't use this because
    #key of the map is web_sg 
    description = string
    vpc_id      = string
    ingress_rules = optional(list(object({
      from_port        = number
      to_port          = number
      description      = string
      protocol         = string
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = optional(list(string))
      security_groups  = optional(list(string))
    })))
    egress_rules = optional(list(object({
      from_port        = number
      to_port          = number
      description      = string
      protocol         = string
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = optional(list(string))
      security_groups  = optional(list(string))
    })))
  }))
}
resource "aws_security_group" "default" {
  for_each    = var.security_group
  name        = each.key               #then we can put here#each.value.name #var.security_group_name #"allow_tls"
  description = each.value.description #var.security_group_description #"Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = each.value.vpc_id      #var.vpc_id
  dynamic "ingress" {
    for_each = each.value.ingress_rules != null ? each.value.ingress_rules : []
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks != null ? ingress.value.ipv6_cidr_blocks : []
      description      = ingress.value.description
      security_groups  = ingress.value.security_groups != null ? ingress.value.security_groups : []
    }
  }
  dynamic "egress" {
    for_each = each.value.egress_rules != null ? each.value.egress_rules : []
    # it says here each.egress rules if it does not equal (!=null)
    #to no use whatever in the each.value.egress rules (? each.value.egress_rules)
    # otherwise don't use it make it empty (: [content {
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks != null ? egress.value.ipv6_cidr_blocks : []
      description      = egress.value.description
      security_groups  = egress.value.security_groups != null ? egress.value.security_groups : []
    }
  }
}
output "security_group_id" {
  value = { for sg in aws_security_group.default : sg.name => sg.id }
}