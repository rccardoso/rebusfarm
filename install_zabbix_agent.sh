#!/bin/bash
echo "Downloading packaging..."

wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i zabbix-release_5.0-1+focal_all.deb

apt update

echo "Installing agent"

apt -y install zabbix-agent

sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"

HOSTNAME=$(hostname)

echo "Configure agent"

cat > /tmp/zabbix_agentd.conf <<EOL
PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=172.16.44.147
ServerActive=172.16.44.147
Hostname=$HOSTNAME
Include=/etc/zabbix/zabbix_agentd.d/*.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=$HOSTNAME
TLSPSKFile=/etc/zabbix/zabbix_agentd.psk
EOL

echo "Restart and enable service"

systemctl restart zabbix-agent
systemctl enable zabbix-agent

echo "Hostname :" echo $HOSTNAME
echo "IP Addresses: "
ip addr | grep inet | grep -v fe | grep -v :: | awk '{print $2}' | sed 's/\/.*//g'
echo "PSK Identity: " cat /etc/zabbix/zabbix_agentd.psk

exit 0