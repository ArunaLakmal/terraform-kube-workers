resource "aws_lb" "int_kube_worker_lb" {
  name               = "kubeworker-int-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${var.private_subnet1}",
  "${var.private_subnet2}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "int_kube_worker_tg" {
  name     = "int-kube-worker-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener" "int_kube_worker_listener" {
    load_balancer_arn = "${aws_lb.int_kube_worker_lb.arn}"
    port = "80"
    protocol = "TCP"

    default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.int_kube_worker_tg.arn}"
  }
}

resource "aws_autoscaling_attachment" "int_lb-kube_worker_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.kube_worker_asg.id}"
  alb_target_group_arn = "${aws_lb_target_group.int_kube_worker_tg.id}"
}