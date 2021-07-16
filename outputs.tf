# AWS Sample Node
output "aws_sample_server" {
  value            = concat(aws_instance.sample_server.*.public_ip, [null])[0]
}
