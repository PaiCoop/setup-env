#!/bin/bash
NAME="PaiCoop"
DOMAIN="paicoop.net"
NOTIFY_EMAIL="i@iotcat.me"
REPOSITORY_URL="https://github.com/IoTcat/PaiCoop"
MAIL_API_URL="https://api.yimian.xyz/mail/"
#############################
#############################
#
# Capture Ctrl+C
trap 'onCtrlC' INT
function onCtrlC () {
    echo  
    echo \#######################################################
    echo                  Script Terminated!!!
    echo \#######################################################
    exit 0
}
#
# Show Tip
echo \############################################################
echo This script will setup a CentOS7 system as a ${NAME} server.
echo When the setup is finished, an email will be sent to ${NOTIFY_EMAIL}.
echo The following information will be used to configure the system:
echo  
echo Name: ${NAME}
echo Domain: ${DOMAIN}
echo Notify_Email: ${NOTIFY_EMAIL}
echo Repository_Url: ${REPOSITORY_URL}
echo Mail_Api_Url: ${MAIL_API_URL}
echo  
echo You may manually modify the script to change these settings.
echo You may use Ctrl+C to terminate the script.
echo Otherwise, the setup will start after 30s.
echo \############################################################
#
# Delay 30s
sleep 30s
#
# To Top Dir
cd /
#############################
#  Setup OS Configuration       
#############################
#
# change hostname
hostname ${DOMAIN}
hostnamectl set-hostname ${DOMAIN}
#
# set welcome banner
echo \######################################>/etc/motd
echo      Welcome to ${DOMAIN} Server!!>>/etc/motd
echo \######################################>>/etc/motd
#############################
#  Setup Dependencies       
#############################
# 
# yum update
yum -y update
yum install epel-release -y
#
# install development tools
yum install -y wget git vim unzip zip openssl make gcc gcc-c++ screen fuse fuse-devel nscd
#
# prevent DNS cache pollution
systemctl start nscd
systemctl enable nscd
nscd -i hosts
echo '52.74.223.119     github.com'>>/etc/hosts
echo '199.232.96.133    raw.githubusercontent.com'>>/etc/hosts
#############################
#  Setup Docker Env       
#############################
#
# install docker
yum -y install docker
systemctl enable docker
systemctl start docker
#
# install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
#############################
#  Firewall Setup           
#############################
# 
# remove firewalld
systemctl stop firewalld
systemctl disable firewalld
#
# stop SELINUX
setenforce 0
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
#
# setup iptables
yum install iptables-services iptables-devel -y
systemctl start iptables
systemctl enable iptables
iptables -A OUTPUT -j ACCEPT
iptables -A INPUT -j REJECT
iptables -A FORWARD -j REJECT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# open port for ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#############################
#  Clone Repository           
#############################
# git clone
#
git clone ${REPOSITORY_URL} /usr/local/src/${NAME}
#############################
#  Setup finished           
#############################
# 
# email notice
curl "${MAIL_API_URL}?to=${NOTIFY_EMAIL}&subject=${DOMAIN} CentOS setup finished&body=CentOS ${DOMAIN} env setup finished!!"
#
# system reboot
reboot
