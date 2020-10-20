data "terraform_remote_state" "core" {
    backend = "s3"

    config = {
        bucket = "${var.bucket}"
        key = "${var.env}/${var.aws_region}/${var.paas_name}/core/terraform.tfstate"
        region = "${var.aws_region}"
    }
}

module "mod" {
    source = "../module"

    vpc_id = "${var.vpc_id != "" ? var.vpc_id : data.terraform_remote_state.core.outputs.vpc_id}"
    public_subnet_id1 = "${var.public_subnet_id1 != "" ? var.public_subnet_id1 : data.terraform_remote_state.core.outputs.public_subnet_id1}"
    public_subnet_id2 = "${var.public_subnet_id2 != "" ? var.public_subnet_id2 : data.terraform_remote_state.core.outputs.public_subnet_id2}"
    kube_sg_id = "${var.kube_sg_id != "" ? var.kube_sg_id : data.terraform_remote_state.core.outputs.kube_sg_id}"
    key_pair = "${var.key_pair != "" ? var.key_pair : data.terraform_remote_state.core.outputs.key_pair}"
    private_subnet1 = "${var.private_subnet1 !="" ? var.private_subnet1 : data.terraform_remote_state.core.outputs.private_subnet_id1}"
    private_subnet2 = "${var.private_subnet2 !="" ? var.private_subnet2 : data.terraform_remote_state.core.outputs.private_subnet_id2}"

    aws_region = "${var.aws_region}"
    aws_profile = "${var.aws_profile}"
    worker_desired_capacity = "${var.worker_desired_capacity}"
}
