#!/bin/bash
### igordc, 20190622    ###
### run as root  user   ###
### ran fine on 16.04.6 ###
### ran fine on 18.04.2 ###

#sudo su -
cd

# CHANGE THIS:
HTTP_PROXY=server.localhost:port
SOCKS_PROXY=server.localhost

# temporary proxy settings
export http_proxy=http://$HTTP_PROXY
export https_proxy=https://$HTTP_PROXY

# and install docker-ce manually, with the following steps
apt-get remove docker docker-engine docker.io containerd runc -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
apt-get install docker-ce docker-ce-cli containerd.io build-essential -y

wget https://raw.githubusercontent.com/crops/chameleonsocks/master/chameleonsocks.sh
sed -i "s/PROXY:=my.proxy.com/PROXY:=$SOCKS_PROXY/" chameleonsocks.sh
sed -i "s/EXCEPTIONS:=\/path\/to\/exceptions\/file/EXCEPTIONS:=chameleonexceptions/" chameleonsocks.sh

touch chameleonexceptions
tee chameleonexceptions << EOF
0.0.0.0/8
127.0.0.0/8
169.254.0.0/16
224.0.0.0/4
240.0.0.0/4
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
10.178.241.0/24
172.25.103.0/24
172.17.0.0/16
192.168.122.0/24
EOF

chmod +x chameleonsocks.sh
./chameleonsocks.sh --install

iptables -t nat -A PREROUTING -i cni0 -p tcp -j CHAMELEONSOCKS
iptables -t nat -A PREROUTING -i virbr0 -p tcp -j CHAMELEONSOCKS
