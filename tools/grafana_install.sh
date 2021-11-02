#!/bin/bash


echo "#########################################"
echo "GRAFANA KURULUMU"
echo "#########################################"

echo "-----------------------------------------"
echo "Repo Olusturuldu"
echo "-----------------------------------------"
cat <<EOF | sudo tee /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

echo "-----------------------------------------"
echo "Grafana installation"
echo "-----------------------------------------"
sudo yum install grafana

echo "----------------------------------------"
echo "Other Installation"
echo "----------------------------------------"
yum install fontconfig
yum install freetype*
yum install urw-fonts


echo "-----------------------------"
echo "Enable Service"
echo "-----------------------------"

systemctl start grafana-server
systemctl status grafana-server
systemctl enable grafana-server.service


echo "-----------------------------"
echo "Firewall Conf."
echo "-----------------------------"

firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload

echo "-----------------------------"
echo "Install plugins"
echo "-----------------------------"
grafana-cli plugins install alexanderzobnin-zabbix-app
systemctl restart grafana-server

iptables -F
setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

ip=$(ifconfig |grep "inet " |egrep -v 127 |cut -d" " -f10)


echo "Bir sorun olusmadiysa http://$ip:3000 erisim saglayabilirisiniz."
echo "Default Username: admin"
echo "Default Password: admin"