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

wget -P /usr/local/bin/ https://gist.githubusercontent.com/ArunaLakmal/265f83e144aa67996d72662556aec33e/raw/2244205d6550059ec4bface97cc065ec732253ef/ansible-wrapper.sh
chmod +x /usr/local/bin/ansible-wrapper.sh

crontab<<EOF
*/5 * * * * ansible-wrapper.sh
EOF

/etc/init.d/cron start