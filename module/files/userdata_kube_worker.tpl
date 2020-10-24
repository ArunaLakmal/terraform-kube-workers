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

wget -P /usr/local/bin/ https://gist.githubusercontent.com/ArunaLakmal/265f83e144aa67996d72662556aec33e/raw/9216b6731dca20257f168f32f8e95b467b796143/ansible-wrapper.sh
wget -P /etc/systemd/system/ https://gist.githubusercontent.com/ArunaLakmal/4b549c7dd7e731d398d794b89b6a6914/raw/b838c86ee1ba0b9bd5f1d1b1a22e2bb122267d18/techcrumble.service
chmod +x /usr/local/bin/ansible-wrapper.sh

crontab<<EOF
*/5 * * * * /bin/systemctl restart techcrumble
EOF

/etc/init.d/cron start
systemctl daemon-reload
systemctl enable techcrumble
systemctl start techcrumble