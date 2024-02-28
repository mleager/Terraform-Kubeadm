# data "aws_instance" "ec2-instance-data" {
#   get_user_data = true

#   filter {
#     name   = "tag:Environment"
#     values = ["dev"]
#   }

#   filter {
#     name   = "tag:Project"
#     values = ["${var.project}"]
#   }
#   depends_on = [module.asg]
# }

# output "ec2-instance-public-ip" {
#   value = data.aws_instance.ec2-instance-data.public_ip
# }

# output "ec2-instance-user-data" {
#   value = data.aws_instance.ec2-instance-data.user_data_base64
# }
