#!/bin/bash


######Repo Dosyası Indiriliyor#######
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm

######Zabbix Agent Indiriliyor#######
yum install -y zabbix-agent

##### Kısıtlamaları Kaldir ######
getenforce 0
iptables -F

### Conf Dosyası Duzenleniyor ####
read -p "Zabbix Server IP Adresini Giriniz : " zabbixip
devicename=$(hostname)
sudo sed -i 's/^Server=.*/Server= '$zabbixip'/g' /etc/zabbix/zabbix_agent.conf
sudo sed -i 's/^Hostname=.*/Hostname= '$devicename'/g' /etc/zabbix/zabbix_agent.conf

##### Servislerin Calismasi ########
systemctl restart zabbix-agent
systemctl enable zabbix-agent

##### Tebrikler Kurulum Gerceklesti #######