#!/bin/bash


echo "#########################################"
echo "GRAYLOG KURULUMU"
echo "#########################################"


sudo yum install epel-release
sudo yum install pwgen nano net-tools
echo "----------------------------------------------------------------"
echo "Selinux Ayarlari"
echo "----------------------------------------------------------------"
sudo yum -y install curl vim policycoreutils python3-policycoreutils


echo "----------------------------------------------------------------"
echo "Javajdk Kurulum"
echo "----------------------------------------------------------------"
sudo yum install java-11-openjdk java-11-openjdk-devel


echo "----------------------------------------------------------------"
echo "Elasticsearch Kurulum"
echo "----------------------------------------------------------------"

cat <<EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/oss-7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sudo yum -y install elasticsearch-oss

sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT

echo "----------------------------------------------------------------"
echo "Elasticsearch Servislerin Baslamasi"
echo "----------------------------------------------------------------"

sudo systemctl daemon-reload
sudo systemctl enable --now elasticsearch
sudo systemctl restart elasticsearch.service
sudo systemctl --type=service --state=active | grep elasticsearch



echo "----------------------------------------------------------------"
echo "MongoDB Kurulum"
echo "----------------------------------------------------------------"

sudo tee /etc/yum.repos.d/mongodb-org-4.repo<<EOF
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOF

sudo yum install mongodb-org

sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl start mongod.service
sudo systemctl --type=service --state=active | grep mongod

sudo firewall-cmd --add-port=27017/tcp --permanent
sudo firewall-cmd --reload



echo "----------------------------------------------------------------"
echo "Graylog Kurulum"
echo "----------------------------------------------------------------"

sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-4.2-repository_latest.rpm
sudo yum install graylog-server

echo "----------------------------------------------------------------"
echo "Graylog Konf."
echo "----------------------------------------------------------------"

pw=$(pwgen -N 1 -s 96)
read -p "Bir UI Sifre Belirleyin : " uipass
pass=$(echo -n $uipass | sha256sum |cut -d" " -f1)
echo $pw
echo $pass


sudo sed -i 's/^password\_secret =.*/password\_secret = '$pw'/g' /etc/graylog/server/server.conf
sudo sed -i 's/^root\_password\_sha2 =.*/root\_password\_sha2 = '$pass'/g' /etc/graylog/server/server.conf
sudo sed -i 's/^root\_email = .*/root\_email = mail\@example\.com/g' /etc/graylog/server/server.conf
sudo sed -i 's/^\#root\_timezone = .*/root\_timezone = Europe\/Istanbul/g' /etc/graylog/server/server.conf
sudo sed -i 's/^\#http\_bind\_address = 127.*/http\_bind\_address = 0\.0\.0\.0\:9000 /g' /etc/graylog/server/server.conf
sudo sed -i 's/^is\_master = .*/is\_master = true/g' /etc/graylog/server/server.conf
sudo sed -i 's/^elasticsearch\_shards = .*/elasticsearch\_shards = 1/g' /etc/graylog/server/server.conf


echo "----------------------------------------------------------------"
echo "Graylog Servis Baslatma"
echo "----------------------------------------------------------------"

systemctl daemon-reload
systemctl restart graylog-server
systemctl enable graylog-server
firewall-cmd --permanent --add-port=9000/tcp
firewall-cmd --reload

iptables -F
setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

ip=$(ifconfig |grep "inet " |egrep -v 127 |cut -d" " -f10)

echo "Bir sorun olusmadiysa http://$ip:9000 erisim saglayabilirisiniz."
echo "Default Username : admin"
echo "Default Password : $uipass"
