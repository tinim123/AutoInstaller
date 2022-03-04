#!/bin/bash



echo "-------------------------------------------"
echo "
  _____ _      _       
 |_   _(_)_ _ (_)_ __  
   | | | | ' \| | '  \ 
   |_| |_|_||_|_|_|_|_|
                       
"
echo "All Source: https://github.com/tinim123\n\n"
echo " "
echo "Automatic Setup Tool"
echo "-------------------------------------------"

echo "
1: Zabbix install v5.0.x
2: Graylog install v4.2.x
3: Grafana install v8.2.x
"
read -p "Please Select App : " app

case $app in
    1) chmod +x ./tools/zabbix_install.sh && ./tools/zabbix_install.sh
    ;;
    2) chmod +x ./tools/graylog_install.sh && ./tools/graylog_install.sh
    ;;
    3) chmod +x ./tools/grafana_install.sh && ./tools/grafana_install.sh
    ;;
    *) echo "Error, Wrong Select!"
esac
