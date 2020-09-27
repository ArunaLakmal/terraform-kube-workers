data "template_file" "user-init-kube-worker" {
  template = "${file("${path.module}/files/userdata_kube_worker.tpl")}"
}

data "aws_iam_policy" "ssm_role_policy" {
  arn = "${var.ssm_role_policy}"
}

data "aws_iam_policy" "ecs_full_access" {
  arn = "${var.ecs_full_access_policy}"
}
