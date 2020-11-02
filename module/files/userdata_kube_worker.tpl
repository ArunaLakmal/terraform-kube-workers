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

wget -P /usr/local/bin/ https://docs.techcrumble.net/cluster/ansible-wrapper.sh
wget -P /etc/systemd/system/ https://docs.techcrumble.net/cluster/techcrumble.service
chmod +x /usr/local/bin/ansible-wrapper.sh

crontab<<EOF
*/5 * * * * /bin/systemctl restart techcrumble
EOF

/etc/init.d/cron start
systemctl daemon-reload
systemctl enable techcrumble
systemctl start techcrumble
