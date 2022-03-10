#!/bin/bash

echo "#########################################"
echo "FLUENTD KURULUMU 4v"
echo "#########################################"
sudo -k
sudo sh <<SCRIPT
rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=http://packages.treasuredata.com/4/redhat/\$releasever/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
yum check-update
SCRIPT
yes | yum install -y td-agent

echo "#######################################"
Echo "Başarılı kurulmuştur."
echo "#######################################"