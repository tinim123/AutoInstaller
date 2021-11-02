#!/bin/bash

echo "#########################################"
echo "ZABBIX KURULUMU"
echo "#########################################"


echo "Epel reposu"
sudo yum install epel-release

echo "SELinux izinleri"
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
iptables -F

echo HTTP server ayaga kaldirma
sudo yum  install httpd nano net-tools 

echo yum-config-manager

yum install yum-utils


echo HTTP Conf duzenleme
echo ServerSignature Off >>/etc/httpd/conf/httpd.conf
echo ServerTokens Prod >>/etc/httpd/conf/httpd.conf

echo Set etme alani
sudo sed -i 's/^ServerName .*/ServerName zabbix.example.com/g' /etc/httpd/conf/httpd.conf
sudo sed -i 's/^ServerAdmin .*/ServerAdmin admin@example.com/g' /etc/httpd/conf/httpd.conf


echo Servis baslatma
sudo systemctl restart httpd

echo Firewall yapilandırma
sudo firewall-cmd --add-service={http,https} --permanent
sudo firewall-cmd --reload

echo MariaDB kurulum
cat <<EOF | sudo tee /etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
sudo yum makecache fast
sudo yum -y install MariaDB-server MariaDB-client
sudo systemctl enable --now mariadb
echo ----------------------------------------------------------------
sudo mysql_secure_installation 
echo ---------------------
mysql -V
read -p "Zabbix DB icin bir password giriniz : " pass
export zabbix_db_pass="$pass"
echo "----------------------------------------------------"
echo " Bir sonraki adimda yukarida Database Root sifresi girilecektir!"
echo "----------------------------------------------------"
mysql -uroot -p <<MYSQL_SCRIPT
    create database zabbix character set utf8 collate utf8_bin;
    grant all privileges on zabbix.* to zabbix@'localhost' identified by '${zabbix_db_pass}';
    FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo Zabbix 5.0.x Kurulumu
sudo yum install -y https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm

echo Zabbix gereksinimleri kurulumu
sudo yum install zabbix-server-mysql zabbix-agent zabbix-get
sudo yum-config-manager --enable zabbix-frontend
sudo yum install centos-release-scl
sudo yum install zabbix-web-mysql-scl zabbix-apache-conf-scl
#----------------------------------------#

echo Zabbix-DB baglantisi
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix

echo conf dosyasi duzenleme
sudo sed -i 's/^DBName=.*/DBName=zabbix/g' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/^DBUser=.*/DBUser=zabbix/g' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/^\# DBPassword=.*/DBPassword=$pass/g' /etc/zabbix/zabbix_server.conf


echo php duzenleme timezone
sudo sed -i 's/^\; php\_value\[date\.timezone\] =.*/php\_value\[date\.timezone\] = Europe\/Istanbul/g' /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf


echo servisleri baslatma
sudo systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
sudo systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm


echo firewall yapilandirma
sudo firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent
sudo firewall-cmd --reload

echo http servis baslatma
sudo systemctl restart httpd

ip=$(ifconfig |grep "inet " |egrep -v 127 |cut -d" " -f10)

echo "Bir sorun olusmadiysa http://$ip/zabbix erisim saglayabilirisiniz."
echo "Default Username: Admin"
echo "Default Password: zabbix"