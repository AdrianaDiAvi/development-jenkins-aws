#!/bin/bash
# shellcheck disable=SC2002,SC2016,SC2216

# setup environment for script.
export all_proxy="http://proxy-dmz.intel.com:912/"
export ftp_proxy="http://proxy-dmz.intel.com:21/"
export http_proxy="http://proxy-dmz.intel.com:912/"
export https_proxy="http://proxy-dmz.intel.com:912/"
export no_proxy="intel.com,.intel.com,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12,localhost,127.0.0.0/8,127.0.0.1"
export socks_proxy="socks://proxy-dmz.intel.com:1080/"
export ALL_PROXY="http://proxy-dmz.intel.com:912/"
export FTP_PROXY="http://proxy-dmz.intel.com:21/"
export HTTP_PROXY="http://proxy-dmz.intel.com:912/"
export HTTPS_PROXY="http://proxy-dmz.intel.com:912/"
export NO_PROXY="intel.com,.intel.com,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12,localhost,127.0.0.0/8,127.0.0.1"
export SOCKS_PROXY="socks://proxy-dmz.intel.com:1080/"

# add proxy information to the environment
tee -a /etc/environment << EOF
all_proxy="http://proxy-dmz.intel.com:912/"
ftp_proxy="http://proxy-dmz.intel.com:21/"
http_proxy="http://proxy-dmz.intel.com:912/"
https_proxy="http://proxy-dmz.intel.com:912/"
no_proxy="intel.com,.intel.com,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12,localhost,127.0.0.0/8,127.0.0.1"
socks_proxy="socks://proxy-dmz.intel.com:1080/"
ALL_PROXY="http://proxy-dmz.intel.com:912/"
FTP_PROXY="http://proxy-dmz.intel.com:912/"
HTTP_PROXY="http://proxy-dmz.intel.com:912/"
HTTPS_PROXY="http://proxy-dmz.intel.com:912/"
NO_PROXY="intel.com,.intel.com,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12,localhost,127.0.0.0/8,127.0.0.1"
SOCKS_PROXY="socks://proxy-dmz.intel.com:1080/"
EOF

cat << EOF > /home/ec2-user/.ssh/config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

yum -y update & wait
yum -y install zip  python3-pip cmake make m4 wget git tmux & wait
yum -y install jq & wait

# Section to install kubectl and cmake
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" & wait
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


#Install Intel certs
wget --no-proxy http://certificates.intel.com/repository/certificates/Intel%20Root%20Certificate%20Chain%20Base64.zip
wget --no-proxy http://certificates.intel.com/repository/certificates/IntelSHA2RootChain-Base64.zip
wget --no-proxy http://certificates.intel.com/repository/certificates/PublicSHA2RootChain-Base64-crosssigned.zip

yum -y install ca-certificates & wait
update-ca-trust enable
unzip "Intel Root Certificate Chain Base64.zip" -d /etc/pki/ca-trust/source/anchors
unzip IntelSHA2RootChain-Base64.zip -d /etc/pki/ca-trust/source/anchors
update-ca-trust extract

# Setup Vulnerability Scan Account - intel IT
wget -4 -e use_proxy=no -q -O - http://isscorp.intel.com/IntelSM_BigFix/33570/package/scan/labscanaccount.sh | bash -s --

#Install docker
sudo amazon-linux-extras install docker & wait
usermod -aG docker ec2-user
newgrp docker

mkdir /etc/systemd/system/docker.service.d
cat << EOF > /etc/systemd/system/docker.service.d/proxy.conf
[Service]
Environment="HTTP_PROXY=http://proxy-dmz.intel.com:912/"
Environment="HTTPS_PROXY=http://proxy-dmz.intel.com:912/"
Environment="NO_PROXY=intel.com,.intel.com,10.0.0.0/8,localhost,127.0.0.0/8,172.16.0.0/12,::1"
EOF

systemctl enable --now docker

#Install Docker-Compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose version

#Dummy dependency for cumulus
cat /dev/zero | ssh-keygen -f /home/ec2-user/.ssh/id_rsa -q -N ""
chown ec2-user /home/ec2-user/.ssh/*

#insecure docker registry
echo '{"insecure-registries": ["10.166.44.134:5000"]}' | sudo tee /etc/docker/daemon.json

systemctl restart docker

#Java client to connect Jenkins
#amazon-linux-extras install -y  java-openjdk11
