#!/bin/bash
POD_CIDR=/tmp/POD_CIDR
if [[  -f "$POD_CIDR" ]]; then
  echo "10.200.$((1 + RANDOM % 250)).0/24" > /tmp/POD_CIDR
else
  touch /tmp/POD_CIDR
  echo "10.200.$((1 + RANDOM % 250)).0/24" > /tmp/POD_CIDR
fi

sudo apt -y update
sudo apt install -y git jq make python3 python3-distutils
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py 
python3 get-pip.py 
pip install botocore boto boto3 ansible awscli
ansible-galaxy collection install community.aws

cat <<EOF | tee /usr/local/bin/ansible-wrapper.sh
#!/bin/bash

ENVIRONMENT_VERSION=$(aws ssm get-parameter --region=us-east-1 --name "/PAAS/REPO/ENVIRONMENT_VERSION" | jq -r '.Parameter.Value')
ENVIRONMENT_REPO=/TechCrumble-PaaS-Environments
ENVIRONMENT_REPO_URL=https://github.com/ArunaLakmal/TechCrumble-PaaS-Environments.git
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
ROLE=$(aws ec2 describe-tags --region=us-east-1 --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=Name" --output=text | cut -f5)
MASTER_REPO=ansible-kube-master
WORKER_REPO=ansible-kubernetes-worker
ETCD_REPO=terraform-kube-etcd
MASTER_REPO_URL=https://github.com/ArunaLakmal/ansible-kubernetes-master.git
WORKER_REPO_URL=https://github.com/ArunaLakmal/ansible-kubernetes-worker.git
ETCD_REPO_URL=https://github.com/ArunaLakmal/ansible-kubernetes-etcd.git
ROOT=/

cd  "$ROOT"
if [[ -d "$ENVIRONMENT_REPO" ]]; then
  rm -rf "$ENVIRONMENT_REPO"
  git clone "$ENVIRONMENT_REPO_URL" --branch "$ENVIRONMENT_VERSION" --single-branch
  cd "$ENVIRONMENT_REPO"
  MASTER_VERSION=$(jq -r '.ansible_kubernetes_master_version' terraform.tfvars.json)
  WORKER_VERSION=$(jq -r '.ansible_kubernetes_worker_version' terraform.tfvars.json)
  ETCD_VERSION=$(jq -r '.ansible_kubernetes_etcd_version' terraform.tfvars.json)
  if [[ "$ROLE" == "kube_master" ]]; then
    git clone "$MASTER_REPO_URL" --branch "$MASTER_VERSION" --single-branch
    make master
  elif [[ "$ROLE" == "kube_worker" ]]; then
    git clone "$WORKER_REPO_URL" --branch "$WORKER_VERSION" --single-branch
    make worker
  elif [[ "$ROLE" == "kube_etcd" ]]; then
    git clone "$ETCD_REPO_URL" --branch "$ETCD_VERSION" --single-branch
    make etcd
  else
    exit 0
  fi
else
  git clone "$ENVIRONMENT_REPO_URL" --branch "$ENVIRONMENT_VERSION" --single-branch
  cd "$ENVIRONMENT_REPO"
  git clone "$MASTER_REPO_URL" --branch "$MASTER_VERSION" --single-branch
  if [[ "$ROLE" == "kube_master" ]]; then
    git clone "$MASTER_REPO_URL" --branch "$MASTER_VERSION" --single-branch
    make master
  elif [[ "$ROLE" == "kube_worker" ]]; then
    git clone "$WORKER_REPO_URL" --branch "$WORKER_VERSION" --single-branch
    make worker
  elif [[ "$ROLE" == "kube_etcd" ]]; then
    git clone "$ETCD_REPO_URL" --branch "$ETCD_VERSION" --single-branch
    make etcd
  else
    exit 0
  fi
fi
EOF

chmod +x /usr/local/bin/ansible-wrapper.sh

crontab<<EOF
*/5 * * * * ansible-wrapper.sh
EOF

/etc/init.d/cron start