## AutoInstaller

This tool auto installs on centos 7 for zabbix, grafana and graylog.

Installation for Centos 7:
```
sudo yum update
sudo yum -y upgrade 
sudo yum -y makecache
git clone https://github.com/tinim123/ZGGAutoInstaller.git
cd AutoInstaller
chmod +x install.sh
./install.sh
```
and have fun :)

# Graylog
 -> Graylog v4.2.x
# Grafana 
 -> Grafana v8.2.x
# Zabbix
 -> Zabbix v5.0.x
# FluentD
 -> td-agent v4.x
# Zabbix Agent
 -> Zabbix Agent v4.x
