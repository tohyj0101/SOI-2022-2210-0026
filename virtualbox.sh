#!/bin/bash
#
# Automatically deploy a Cuckoo sandbox

function downloadAgent() {
	# Agent.ova is a Windows7 (x86) virtual machine and used to be an Cuckoo agent
	url="https://drive.google.com/uc?export=download&id=1y-XALL3LhDxW6172ytFMDFADxLZD2olR"
	# Download from google drive
	gdown --speed=50MB $url -O ~/Downloads/Agent.ova
}

function configureVirtualbox() {
	# Create hostonly ethernet adapter
	vboxmanage hostonlyif create && vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0

	# Change the default storage directory and permission
	sudo chmod 777 /data/VirtualBoxVms
	vboxmanage setproperty machinefolder /data/VirtualBoxVms

	# Import Agent.ova and take a snapshot
	vboxmanage import $1 && vboxmanage modifyvm "Agent" --name "cuckoo1" && vboxmanage startvm "cuckoo1" --type headless
	sleep 3m
	vboxmanage snapshot "cuckoo1" take "snap1" && vboxmanage controlvm "cuckoo1" poweroff && vboxmanage "cuckoo1" restorecurrent
}

function configureNetwork() {
	# Configure tcpdump
	sudo aa-disable /usr/sbin/tcpdump && sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

	# Open Ip forwarding
	sudo iptables -A FORWARD -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT && sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A POSTROUTING -t nat -j MASQUERADE
	sudo sed -i "s/#net.ipv4.ip_forward=/net.ipv4.ip_forward=/g" /etc/sysctl.conf

	# Configuration persistence
	sudo sysctl -p /etc/sysctl.conf && sudo netfilter-persistent save

	# Configure system DNS
	sudo sed -i "s/127.0.0.53/8.8.8.8/g" /etc/resolv.conf

}

echo -e "\033[41;30m------------------------------\033[0m"
echo -e "\033[41;30m Step 1: Configure VirtualBox \033[0m"
echo -e "\033[41;30m------------------------------\033[0m"
configureVirtualbox ~/Downloads/Agent.ova

echo -e "\033[41;30m---------------------------\033[0m"
echo -e "\033[41;30m Step 2: Configure Network \033[0m"
echo -e "\033[41;30m---------------------------\033[0m"
configureNetwork

echo -e "\033[41;30m-----------------------------\033[0m"
echo -e "\033[41;30m Step 3: Run Cuckoo services \033[0m"
echo -e "\033[41;30m-----------------------------\033[0m"
cuckoo &> ~/Desktop/cuckoo.log &
cuckoo web -H 0.0.0.0 -p 8000 &> ~/Desktop/cuckoo_web.log &

echo -e "\033[42;30m-----------------------------------------------\033[0m"
echo -e "\033[42;30m Done! Cuckoo web service running on port 8000 \033[0m"
echo -e "\033[42;30m-----------------------------------------------\033[0m"
