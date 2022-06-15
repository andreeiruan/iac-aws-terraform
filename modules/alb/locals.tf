locals {
  ports_sg_alb = [
    443, 80, var.blue_port, var.green_port
  ] 
}
